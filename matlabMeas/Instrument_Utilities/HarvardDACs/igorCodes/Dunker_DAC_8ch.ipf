#pragma rtGlobals=1		// Use modern global access method.

//Written be Jeff Miller, Spring 2001
//This IPF contains the SetDAC() function to use the Jim MacArthur 20-bit D/A board
//InitDAC() should always be executed in each experiment before using the D/A
// DACRange AND DACOffset must be calibrated by the user!!!!!!!

//Modifications by Dominik "Max" Zumbuhl, 6/15/01
// made some finetuning adjustments :-)

macro Flipper(chan)
	variable chan
	variable i=0
	pauseupdate; silent 1
	do
		setDAC(chan,-50)
		wait(.1)
		setDAC(chan,50)
		wait(.1)
		i += 1
	while (i < 20000)
end


macro InitDAC()
	pauseupdate; silent 1

	variable/G NumChan=16				//# of available chanels 	(4 (or 8 if two boards present))
	variable/G ingot=1 					//ingot = 1 : ingot present and the used D/A board

	VDTOperationsPort COM1				//Designate COM1 as the DAC control port
//	VDTOperationsPort COM3   //Use COM3 for PXI bus
	VDT baud=57600, stopbits=1, databits=8, parity=0, in=0, out=0, echo=0, buffer=32767	//Set protocol
	if(!waveexists($"DACRange"))
		make/O/N=(NumChan) $"DACRange" 	//Define the full range of the DAC
	endif
	if(!waveexists($"DACOffset"))
		make/O/N=(NumChan) $"DACOffset" 	//Define the zero offset
	endif
	if(!waveexists($"DACDivider"))
		make/O/N=(NumChan) $"DACDivider" 	//Define the DACDivider value
	endif
	if(!waveexists($"DACLimit"))
		make/O/N=(NumChan) $"DACLimit" //Selfimposed voltagelimit to prevent blowing up your devices
	endif
	if(!waveexists($"DACLabel"))
		make/O/T/N=(NumChan) $"DACLabel"=""	// textwave for naming a channel
	endif

	variable/G INGOTRAMPSTEPC=20		// mV per step when ramping a coarse channel
	variable/G INGOTRAMPSTEPF=1		// mV per step when ramping a fine channel
	variable/G INGOTRAMPDELAY=.01		// seconds of delay per step
	
	//adjusted on 3-30-06
	DACRange[0] = 10007.5								//these numbers here have to be determined experimentally
	DACOffset[0] = 0.124766       				      			//hooking up a DMM (runing in, say, fast 6 digits mode)
	DACRange[1] = 10006.5								//and runing the CalDac(chan)/initdac routines a few times until 
	DACOffset[1] =  0.0164657  //adjusted 11/15/08 MDS
	DACRange[2] = 9793.35
	DACOffset[2] = -4
	DACRange[3] = 9788.25
	DACOffset[3] = -7
	DACRange[4] = 9793.06
	DACOffset[4] = -5.7
	DACRange[5] = 9800.83
	DACOffset[5] = -3
	DACRange[6] = 9803.68
	DACOffset[6] = -0.8
	DACRange[7] = 9789
	DACOffset[7] = -2.1
	DACRange[8] = 9833.25
	DACOffset[8] =1	
	DACRange[9] =9857.72
	DACOffset[9] = -0
	DACRange[10] = 9822.52
	DACOffset[10] = -9
	DACRange[11] =9829
	DACOffset[11] = -4
	DACRange[12] = 9837
	DACOffset[12] = -6
	DACRange[13] = 9822.78
	DACOffset[13] = -8
	
	//rest not used yet
	DACRange[14] = 9799
	DACOffset[14] = -4.12
	DACRange[15] = 9804.8
	DACOffset[15] = -5.85

	variable divider=6
	DACDivider[0] = divider//96.16//<--- for use with PS310
	DACDivider[1] = divider				//if you use a Voltage divider on output of DAC
	DACDivider[2] = divider					//put the amount it divides by here and you won't
	DACDivider[3] = divider					//ever have to convert any Voltages in your head
	DACDivider[4] = divider
	DACDivider[5] = divider
	DACDivider[6] = divider
	DACDivider[7] = divider
	DACDivider[8] = divider	
	DACDivider[9] = divider
	DACDivider[10] = divider
	DACDivider[11] = divider
	DACDivider[12] = divider						//ever have to convert any Voltages in your head
	DACDivider[13] = divider	//1/31/06
	DACDivider[14] = divider
	DACDivider[15] = divider
	
	
	
	DACLimit[0] = 10000/DACDivider[0]	//this is the maximum range obtainable after the divider
	DACLimit[1] = 10000/DACDivider[1]
	DACLimit[2] = 10000/DACDivider[2]
	DACLimit[3] = 10000/DACDivider[3]
	DACLimit[4] = 10000/DACDivider[4]
	DACLimit[5] = 10000/DACDivider[5]
	DACLimit[6] = 10000/DACDivider[6]
	DACLimit[7] = 10000/DACDivider[7]			
	DACLimit[8] = 10000/DACDivider[8]			
	DACLimit[9] = 10000/DACDivider[9]			
	DACLimit[10] = 10000/DACDivider[10]			
	DACLimit[11] = 10000/DACDivider[11]	
	DACLimit[12] = 10000/DACDivider[12]
	DACLimit[13] = 10000/DACDivider[13]
	DACLimit[14] = 10000/DACDivider[14]
	DACLimit[15] = 10000/DACDivider[15]		
	
//	Make/o/N=(NumChan) DAC			//this keeps track of what the outputs are currently set to
	
//	SetDac(0,0)			//set all channels to 0
//	SetDac(1,0)
//	SetDac(2,0)
//	SetDac(3,0)
//	SetDac(4,0)
//	SetDac(5,0)
//	SetDac(6,0)
//	SetDac(7,0)
//	SetDac(8,0)	
//	SetDac(9,0)
//	SetDac(10,0)
//	SetDac(11,0)
//	SetDac(12,0)
//	SetDac(13,0)
//	SetDac(14,0)
//	SetDac(15,0)
	
//	if(wintype("DACstatus")==0)
//		Edit/W=(498.75,38,762,200.75) DACLabel,DAC,DACDivider,DACLimit,DACoffset,DACrange as "DACstatus"
//		ModifyTable size=9,width(Point)=26,title(Point)="Chan",width(DACLabel)=68,sigDigits(DAC)=4
//		ModifyTable width(DAC)=69,sigDigits(DACDivider)=4,width(DACDivider)=38,width(DACLimit)=45
//	endif

End

function LimitDAC(chan,mV)				//change the maximum Voltage the Ingot lets you put out
	variable chan
	variable mV
	variable/G NumChan
	wave DACLimit=DACLimit	//A safety check to prevent stoping your experiment earlier than anticipated
	
	if ((chan>=0 %& chan<NumChan) %& (mV>1 %& mV<10000))
		DACLimit[chan]=mV
	else
		print "LimitIngot: range violation: 0<=chan<=", NumChan,", 1mV<=mV<=10000mV"
	endif
	
End

function chanramp(chan,mv)	// ramps the total value of chan to mv, leaving the other channel untouched if linked
	variable chan
	variable mv
	
	variable/G NumChan
	wave DAC=DAC

	variable/G INGOTRAMPSTEPC	// defined in IngotDAC()
	variable/G INGOTRAMPSTEPF
	variable/G INGOTRAMPDELAY

	if(chan<0 || chan>NumChan-1)
		printf "chan %d invalid\r",chan
		return 0 
	endif
	
	variable rampstep=NaN		// actual step to be used this time
	variable mvstart=NaN
 
	mvstart=DAC(chan)
	rampstep=INGOTRAMPSTEPC

	if (abs(mvstart-mV)>100)
		// cut rampstep down a little to avoid having to take a half-step at the end, and fix the sign
		variable numsteps=ceil(abs((mv-mvstart)/rampstep))
		rampstep=(mv-mvstart)/numsteps
		variable i=0
		do
			i+=1
			wait(INGOTRAMPDELAY)
			SetDAC(chan,(mvstart+i*rampstep))
			// put in a wait here?
		while(i<numsteps)
	endif
	
	SetDAC(chan,mv)		// make sure there's no rounding error at the end
end

Function SetDAC(chan, mV) 	//set chan # chan to Voltage mV in millivolts 
	variable chan, mV			//(with 20-bit digitization error, of course)
	
	variable/G NumChan
	wave DAC = DAC								// used to keep track of outputs 
	wave DACLimit = DACLimit			// user defined limits
	wave DACDivider = DACDivider					// used if divider is put on output of box
	wave DACOffset = DACOffset
	wave DACRange = DACRange
	
	if ((chan<NumChan) && (chan>=0))
	
   	if (abs(mV)>abs(DACLimit[chan])) 
   		beep
 		print  "setDAC: range violation, chan: ", chan,", range: ", DACLimit[chan], "mV, attempt. setvolt.: ", mv, "mV"
   	elseif(numtype(mV))
   		print "setDAC: trying to set chan to non-numeric value", mV
   	else

	mV = mV*DACDivider[chan]		//for convenience, such that user doesn't have to keep in mind the divider

	//determine the digitized value, i.e. the bin number, corresponding to mV that the DAC has to be set to
	//this DAC is 20bit, the physical range is fixed at -10V to +10V, i.e. binsize = 20/2^20= about 19 microvolts
	// if there is a voltage divider at the output of the box, binsize is divided by the value of the divider :-)
	
 	Variable bin = floor(524288+((mV-DACOffset[chan])*524288/DACRange[chan]))	
		//this includes peculiarities for each channel such as range and offset, stored in corresp. global arrays
		
	if (bin > 1048575) 	// largest possible bin number
		printf "SetDAC: Cannot set DAC to such a large positive value! Set to Maximum \r"
	    bin = 1048575
	endif
	if (bin < 0)	//smallest possible bin number
		printf "SetDAC: Cannot set DAC to such a large negative value! Setting to Minimum \r"
		bin = 0
	endif

	SetDACBin(chan, bin)		//call a more primitive setdac routine that needs to know the
							//digitized bin number as input

	mV= ((bin-524288)*DACRange[chan]/524288)+DACOffset[chan]	//update the DAC wave with the
   	DAC[chan] = mV/DACDivider[chan]								//actual voltage the DAC was set to
   																//(as opposed to what the user wanted
   	endif														// it to be (difference is due to digitization))
   	endif
End

Function SetDACBin(chan, bin)		//set channel # chan to bin # bin
	variable chan, bin
						// the three 20bit components
	variable/G by1		//by1: most significant
	variable/G by2
	variable/G by3		//by3: least significant
	variable device
	variable IanChan
	variable IDby, CommandBy, parity
	string cmd
//	NVAR check=check

	sprintf cmd, "VDT killio"
 	execute cmd					

	if ((chan<=3) && (chan>=0)) 	// Figure out which board is being used.  Assign the correct device 
		device = 1				//number and use the correct channel on that device number only in the commandbyte.
		IanChan = chan			//Keep chan as the correct "software" channel number.
	else // ie, use device #2
		if (chan<=7)
			device = 2
			IanChan = chan-4
		else
			if (chan <= 11)
				device = 3
				IanChan = chan-8
			else
				if (chan <= 15)
					device = 4
					IanChan = chan-12
				endif
			endif
		endif
	endif
			
	IDBy = 192+device		//Set ID byte to "11dddddd" where dddddd is the device ID
	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",IDby
	execute cmd				//Send Byte 1 = ID byte
//	sprintf cmd, "VDTreadbinary/o=1 check"
//	execute cmd
//	print check
	Commandby = 64+IanChan 	//Update DAC Channel "010000cc" where cc is the channel number
	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",Commandby
	execute cmd				//Send Byte 2 = Command Byte (Command 01000001 Update Channel 1)  
		
	Conv20Bit(bin,chan)		//Convert 20 bit bin # to 2 x 8bit and 1 x 7bit number (all decimal numbers)
							//return in the global variables by1 (most sign.), by2, and by3 (least sig.)

	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",by1
 	execute cmd				//First Byte of Data 00aaaaaa
        
	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",by2
	execute cmd				//Second Byte of Data 0bbbbbbb
        
	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",by3
	execute cmd				//Third Byte of Data 0ccccccc
        
	//The data sent are 20-bit data of the form aaaaaabbbbbbbccccccc

	parity = (IDby%^Commandby%^by1%^by2%^by3)	//The parity byte is the XOR of all the bytes in the command 
	if (parity>=128)     					//If the parity byte is greater than of equal to 128
		parity -= 128  					//Subtract off the first bit  
	endif
	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",parity
	execute cmd		          				//Write the parity byte
	sprintf cmd, "VDTWriteBinary /O=10/F=2 %d",0
	execute cmd							//Zero-pad, Status.  Host sends a byte set to ZERO.
end

Function Conv20Bit(bin,chan)	//To decompose a 20bit number into 7bit, 8bit, 8bit
	Variable bin, chan		//bin is the bin or subdivision number that the channel is supposed to be set to
							// (bin not equal to binary!! all numbers are decimal)
	variable/G by1
	variable/G by2
	variable/G by3
	variable dum, dum2	
	
	dum=floor(bin/128)*128		//extract the 8 least significant bits
	by3=bin-dum

	dum/=128					//extract the middle 8 significant bits
	dum2=floor(dum/128)*128
	by2=dum-dum2
	
	by1=dum2/128				//extract the 7 most significant bits
end								//this is an integer because of floor in def. of dec	

macro CalDAC(chan)				//Calibrate DAC chanel # chan
	variable chan					//hook up a DMM on the chanel that you want to calibrate
	silent 1; pauseupdate			//this will determine the parameters:
								//DACRange and DACOffset and PRINT them on the commandline
								//the user must implement these numbers her/himself
								//(to be found in the InitDAC macro)
								//recommended DMM setting: fast 6 digits

	Make/D/O/N=101 DACCAL = NaN
	make/D/O/N=11  DACAVG = NaN
	Make/D/O/N=11  OfsAVG = NaN
	variable i,j,k = 0
	variable step = 0
	variable ofs = 0
	variable low=0,mid=0,high=0

//	print DACLimit[chan]/2
	setDAC(chan, -DACLimit[chan]/2)
	wait(1)
	do								//take average over 20 readouts to get accurate measurment
	    //daccal[k] = readdmm(dmm0)
	    daccal[k] = ReadDAQmx(0)   //set up for PXI system, 8-22-07, J.P.
	    low+= daccal[k]
	    i += 1
	    k += 1
	    doupdate
	while (i < 10)
	i=0
	setDAC(chan, 000)
	wait(1)
	do								//take average over 20 readouts to get accurate measurment
	    //daccal[k] = readdmm(dmm0)
	    daccal[k] = ReadDAQmx(0)    //set up for PXI system, 8-22-07, J.P.
	    mid+= daccal[k]
	    i += 1
	    k += 1
	    doupdate
	while (i < 10)
	i = 0
	setDAC(chan, DACLimit[chan]/2)
	wait(1)
	do								//take average over 20 readouts to get accurate measurment
	    //daccal[k] = readdmm(dmm0)
	    daccal[k] =ReadDAQmx(0)    //set up for PXI system, 8-22-07, J.P.
	    high+= daccal[k]
	    i += 1
	    k += 1
	    doupdate
	while (i < 10)

	low = low/10
	mid = mid/10
	high = high/10
	
	print "Recommended DACRange: ", DACRange[chan]+DACDivider[chan]*(high-low-DACLimit[chan]), "Current DACRange:", DACRange[chan]
	print "Recommended DACOffset", mid+DACOffset[chan], "Current DACOffset: ", DACOffset[chan]
end

macro AllCalDAC()
	print "Channel 0"
	QuickCal(0)
	print "Channel1"
	QuickCal(1)
	print "Channel 2"
	QuickCal(2)
	print "Channel 3"
	QuickCal(3)
	Beep
end
		
Function SetDACStozero() 	//sets all channels to zero
	SetDac(0,0)
	SetDac(1,0)
	SetDac(2,0)
	SetDac(3,0)
	SetDac(4,0)
	SetDac(5,0)
	SetDac(6,0)
	SetDac(7,0)
	SetDac(8,0)	
	SetDac(9,0)
	SetDac(10,0)
	SetDac(11,0)
	SetDac(12,0)
	SetDac(13,0)
	SetDac(14,0)
	SetDac(15,0)
	
End
