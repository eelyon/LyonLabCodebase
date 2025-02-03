startFreq = 100;
stopFreq = 5e6;
numPoints = 1001;

fprintf(fieldFox,'*CLS\n');
fprintf(fieldFox,'SYST:ERR?\n');
initErrCheck = fscanf(fieldFox,'%c')

fprintf(fieldFox, ['FREQ:STAR ',num2str(startFreq),';STOP ',num2str(stopFreq),'\n'])
% Set number of trace points
fprintf(fieldFox,['SWE:POIN ' num2str(numPoints), '\n'])

fprintf(fieldFox,'INIT:CONT 0\n');
fprintf(fieldFox,'INIT;*OPC?\n')
trigComplete = fscanf(fieldFox,'%1d')
%Query FORMATTED data from fieldFox
% Set data format to real-32 bin block transfer
fprintf(fieldFox, 'FORM:DATA REAL,32\n')
fprintf(fieldFox, 'TRACE:DATA?')
myBinData = binblockread(fieldFox,'float');
xDat = linspace(startFreq,stopFreq,numPoints);
myBinData = myBinData.*1e9/(10.3*20); % Add x20 Vgain for FEMTO at 20dB
[handle,myFig] = plotData(xDat,myBinData,'xLabel',"Frequency (Hz)",'yLabel',"nV/Hz",'color',"r-",'type', "loglog");
annotation('textbox',[0.2 0.5 0.3 0.3],'String',"295K PSD Choked, x10.3 Amp Gain, x20 FEMTO gain",'FitBoxToText','on');
saveData(myFig,'PSD');
% % There will be a line feed not read, i.e. hanging. Read it to clear
% %buffer.
% % If you do not read the hanging line feed a -410, "Query Interrupted
% % Error" will occur
% hangLineFeed = fread(fieldFox,1);
% 
% fprintf(fieldFox, 'FORM:DATA REAL,64\n')
% fprintf(fieldFox,'SENS:FREQ:DATA?\n')
% myBinStimulusData = binblockread(fieldFox,'double')
% % There will be a line feed not read, i.e. hanging. Read it to clear
% %buffer.
% hangLineFeed = fread(fieldFox,1)
% % Within the MatLab GUI display data and stimulus numbers and plot same
% display myBinData
% display myBinStimulusData
% % MatLab plot related commands and efforts:
% % Convert FieldFox returned frequency data to units of MHz
% myStimulusDataMHz = myBinStimulusData
% clear title xlabel ylabel
% plot(myStimulusDataMHz, myBinData)
% xlabel('Frequency (MHz)')
% ylabel ('PSD (dB/Hz)')
% % Check Error Queue. A "*CLS" was asserted at the beginning of the
% % application. This will clear the entire error queue. Upon completion of
% % the application the error queue is queried a final time. If the
% % application is written correctly and there are no hardware failures the
% % final error query check via 'SYST:ERR?' should return '0, "No Error" else
% % the application is in error.
% fprintf(fieldFox, 'SYST:ERR?')
% finalErrCheck = fscanf(fieldFox, '%c')