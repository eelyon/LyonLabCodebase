#pragma rtGlobals=1		// Use modern global access method.

strconstant HARVARD_DAC_PREFIX = "hvc"

//folder for storing variables
static strconstant HARVARDDACFOLDER = "HARVARDDACs"
static constant NUMCHANS = 32

static constant DAC_RAMP_STEPSIZE_MV = 20		// mV per step when ramping a coarse channel
static constant DAC_RAMP_WAITTIME = .005		// seconds of delay per step
static constant DAC_USE_RAMP = 1

function InitDAC(COMport)
	string COMport

	execute "VDTOperationsPort2 "+COMport
	VDT2 baud=57600, stopbits=1, databits=8, parity=0, in=0, out=0, echo=0, buffer=32767
	
	DeclareHarvardDACVariables()
	
	if(wintype("DACstatus")==0)
		makeDACTable()
	endif

End

static function DeclareHarvardDACVariables()

	InitializeDataFolder(HARVARDDACFOLDER)
	
	DFREF dfr = getHarvardDACdfr()
	if(!waveexists(dfr:DACRange))
		make/o/n=(NUMCHANS) dfr:DACRange = 1e4
	endif
	if(!waveexists(dfr:DACOffset))
		make/o/n=(NUMCHANS) dfr:DACOffset = 0
	endif
	if(!waveexists(dfr:DACDivider))
		make/o/n=(NUMCHANS) dfr:DACDivider = 6
	endif
	if(!waveexists(dfr:DACLimit))
		wave divider = dfr:DACDivider
		make/o/n=(NUMCHANS) dfr:DACLimit = 10000/divider[p]
	endif
	if(!waveexists(dfr:DACLabel))
		make/o/t/n=(NUMCHANS) dfr:DACLabel=""
	endif
	if(!waveexists(dfr:DAC))
		make/o/n=(NUMCHANS) dfr:DAC = 0
	endif
	if(!waveexists(dfr:DACMin))
		make/o/n=(NUMCHANS) dfr:DACMin = -300
	endif
	if(!waveexists(dfr:DACMax))
		make/o/n=(NUMCHANS) dfr:DACMax = 800
	endif
	
	variable/g dfr:by1 = 0, dfr:by2 = 0, dfr:by3 = 0
	
	// Define HarvardDAC_config() function in internal.ipf
	// to use your own system specific settings other than defaults above
#if Exists("HarvardDAC_config")
	HarvardDAC_config()
#else
	print "WARNING: You haven't implemented a HarvardDAC_config() function in your internal.ipf. Using default settings."
#endif
	
end

function/DF getHarvardDACdfr()

	DFREF dfr = $("root:"+HARVARDDACFOLDER)
	return dfr

end

function/S getDACChanLabel(int chanNum)

	DFREF dfr = getHarvardDACdfr()
	wave/T dacLabels = dfr:DACLabel
	string ret = dacLabels[chanNum]
	
	return ret	

end

function LimitDAC(int chan, variable mV)
	DFREF dfr = getHarvardDACdfr()
	wave DACLimit=dfr:DACLimit
	
	if ((chan>=0 && chan<NUMCHANS) && (mV>1 && mV<10000))
		DACLimit[chan]=mV
	else
		string msg
		sprintf msg, "LimitIngot: range violation: 0<=chan<=%d, 1mV<=mV<=10000mV", NUMCHANS
		abort msg
	endif
End

function chanramp(int chan, variable mv)
	DFREF dfr = getHarvardDACdfr()
	wave DAC=dfr:DAC

	if(chan<0 || chan>NumChans-1)
		string msg
		sprintf msg, "chan %d invalid",chan
		abort msg
		return -1 
	endif
	
	if(DAC_USE_RAMP == 0)
		setDAC(chan,mv)
	else
	
		variable mvstart=DAC[chan]
		variable rampstep = DAC_RAMP_STEPSIZE_MV

		if (abs(mvstart-mV)>DAC_RAMP_STEPSIZE_MV)
			variable numsteps=ceil(abs((mv-mvstart)/DAC_RAMP_STEPSIZE_MV))
			rampstep=(mv-mvstart)/numsteps
			int i
			for(i=0;i<numsteps;i++)
				wait(DAC_RAMP_WAITTIME)
				SetDAC(chan,(mvstart+i*rampstep))
			endfor
		endif
		SetDAC(chan,mv) // making sure there are no rounding errors
	endif
end

static function SetDAC(int chan, variable mV) 	//set chan # chan to Voltage mV in millivolts 
	
	DFREF dfr = getHarvardDACdfr()
	wave DAC = dfr:DAC								
	wave DACLimit = dfr:DACLimit			
	wave DACDivider = dfr:DACDivider					
	wave DACOffset = dfr:DACOffset
	wave DACRange = dfr:DACRange
	
	if (chan>=NUMCHANS || chan<0)
		abort "Channel number is out of range!"
		return -1
	endif
	
	string msg
   	if (abs(mV)>DACLimit[chan]) 
   		sprintf msg, "setDAC: range violation, chan: %d, range: %f mV, attempt. setvolt.: %f mV",chan, DACLimit[chan],mv
 		abort msg
   	elseif(numtype(mV))
   		print "setDAC: trying to set chan to non-numeric value ", mV
   		abort "see command line for error message"
   	else

	mV = mV*DACDivider[chan]		//for convenience, such that user doesn't have to keep in mind the divider

	//determine the digitized value, i.e. the bin number, corresponding to mV that the DAC has to be set to
	//this DAC is 20bit, the physical range is fixed at -10V to +10V, i.e. binsize = 20/2^20= about 19 microvolts
	// if there is a voltage divider at the output of the box, binsize is divided by the value of the divider :-)
	
 	variable bin = floor(2^19+((mV+DACOffset[chan])*(2^19)/DACRange[chan]))	
		//this includes peculiarities for each channel such as range and offset, stored in corresp. global arrays
		
	if (bin > 2^20-1) 	// largest possible bin number
		printf "SetDAC: Cannot set DAC to such a large positive value! Set to Maximum \r"
	    bin = 2^20-1
	endif
	if (bin < 0)	//smallest possible bin number
		printf "SetDAC: Cannot set DAC to such a large negative value! Setting to Minimum \r"
		bin = 0
	endif

	SetDACBin(chan, bin)

	mV= ((bin-2^19)*DACRange[chan]/2^19)-DACOffset[chan]
   	DAC[chan] = mV/DACDivider[chan]					
   																
   	endif												
End

Function SetDACBin(int chan, int bin)	
	DFREF dfr = getHarvardDACdfr()
	NVAR by1 = dfr:by1, by2 = dfr:by2, by3 = dfr:by3
	variable device
	variable IanChan
	variable IDby, CommandBy, parity
	string cmd

 	execute "VDT2 killio"	
 	
 	device = floor(chan/4)+1	
 	IanChan = mod(chan,4)			
		
	IDBy = 192+device		//Set ID byte to "11dddddd" where dddddd is the device ID
	sprintf cmd, "VDTWriteBinary2 /O=10 %d",IDby
	execute cmd
	Commandby = 64+IanChan 	//Update DAC Channel "010000cc" where cc is the channel number
	sprintf cmd, "VDTWriteBinary2 /O=10 %d",Commandby
	execute cmd				//Send Byte 2 = Command Byte (Command 01000001 Update Channel 1)  
		
	Conv20Bit(bin,chan)		//Convert 20 bit bin # to 2 x 8bit and 1 x 7bit number (all decimal numbers)
							//return in the global variables by1 (most sign.), by2, and by3 (least sig.)

	sprintf cmd, "VDTWriteBinary2 /O=10 %d",by1
 	execute cmd				//First Byte of Data 00aaaaaa
        
		sprintf cmd, "VDTWriteBinary2 /O=10 %d",by2
	execute cmd				//Second Byte of Data 0bbbbbbb
        
	sprintf cmd, "VDTWriteBinary2 /O=10 %d",by3
	execute cmd				//Third Byte of Data 0ccccccc
        
	//The data sent are 20-bit data of the form aaaaaabbbbbbbccccccc

	parity = (IDby%^Commandby%^by1%^by2%^by3)	//The parity byte is the XOR of all the bytes in the command 
	if (parity>=128)     					//If the parity byte is greater than of equal to 128
		parity -= 128  					//Subtract off the first bit  
	endif
	sprintf cmd, "VDTWriteBinary2 /O=10 %d",parity
	execute cmd		          		//Write the parity byte
	sprintf cmd, "VDTWriteBinary2 /O=10 %d",0
	execute cmd							//Zero-pad, Status.  Host sends a byte set to ZERO.
end

//To decompose a 20bit number into 7bit, 8bit, 8bit
//bin is the bin or subdivision number that the channel is supposed to be set to
// (bin not equal to binary!! all numbers are decimal)
Function Conv20Bit(int bin, int chan)	
	DFREF dfr = getHarvardDACdfr()
	NVAR by1 = dfr:by1, by2 = dfr:by2, by3 = dfr:by3
	variable dum, dum2	
	
	int bytemask = 0xFF
	dum=floor(bin/128)*128		//extract the 8 least significant bits
	by3=bin-dum

	dum/=128						//extract the middle 8 significant bits
	dum2=floor(dum/128)*128
	by2=dum-dum2
	
	by1=dum2/128					//extract the 7 most significant bits
end									//this is an integer because of floor in def. of dec	

//Calibrate DAC chanel # chan hook up a DMM on the chanel that you want to calibrate
//this will determine the parameters: DACRange and DACOffset and PRINT them on the commandline
//the user must implement these numbers her/himself (to be found in the InitDAC macro)
//recommended DMM setting: fast 6 digits
function CalDAC(int chan, int DAQchan)										

	DFREF dfr = getHarvardDACdfr()
	wave DACLimit = dfr:DACLimit
	wave DACRange = dfr:DACRange
	wave DACOffset = dfr:DACOffset
	wave DACDivider = dfr:DACDivider
	
	variable low=0,mid=0,high=0
	setDAC(chan, -DACLimit[chan]/2)
	wait(2)
	low = readDAQAveraged(DAQchan,acqTime=1,sampleRate=1e5) // read for 1s, 100kS
	setDAC(chan, 0)
	wait(2)
	mid = readDAQAveraged(DAQchan,acqTime=1,sampleRate=1e5)
	setDAC(chan, DACLimit[chan]/2)
	wait(2)
	high = readDAQAveraged(DAQchan,acqTime=1,sampleRate=1e5)
	
	// DACRange is defined before Divider, 10V means from -10 to 10V
	// DACOffset is now also defined before Divider, changed sign
	print "Recommended DACRange: ", DACRange[chan]+DACDivider[chan]*(high-low-DACLimit[chan]), "Current DACRange:", DACRange[chan]
	print "Recommended DACOffset", -mid*DACDivider[chan]+DACOffset[chan], "Current DACOffset: ", DACOffset[chan]
end

function makeDACTable()
	DFREF dfr = getHarvardDACdfr()	
	PauseUpdate; Silent 1		// building window...
	Edit/W=(498.75,38,762,200.75) dfr:DACLabel,dfr:DAC,dfr:DACDivider,dfr:DACLimit,dfr:DACMin,dfr:DACMax as "DACstatus"
	ModifyTable size=9,width(Point)=26,title(Point)="Chan",width(dfr:DACLabel)=68,sigDigits(dfr:DAC)=4
	ModifyTable width(dfr:DAC)=50,sigDigits(dfr:DACDivider)=4,width(dfr:DACDivider)=30,width(dfr:DACLimit)=45,width(dfr:DACMin)=30,width(dfr:DACMax)=30
	ModifyTable title(dfr:DACLabel)="Name",title(dfr:DAC)="DAC (mV)",title(dfr:DACDivider)="Div",title(dfr:DACMin)="Min",title(dfr:DACMax)="Max",title(dfr:DACLimit)="Limit"
end

Window DACstatus() : Table
	makeDACTable()
EndMacro

function/s getHarvardDACWaveNote()
	string DACNote="HarvardDAC\r-------------------------\r"
	
	DFREF dfr = getHarvardDACDFR()	
	
	int i
	wave/T DACLabel = dfr:DACLabel
	wave DACV = dfr:DAC
	for(i=0;i<=NUMCHANS;i++)

		DACNote += "c"+num2str(i)+" ("+DACLabel[i]+") = " + num2str(DACV[i]) + "\r"
		
	endfor
	DACNote += "-------------------------"
	
	return DACNote

end