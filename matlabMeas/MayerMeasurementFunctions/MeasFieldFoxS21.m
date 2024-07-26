% 'SYST:ERR?' error query and ensure the error indication is '0, "No
%Error".
fprintf(fieldFox,'*CLS\n');
fprintf(fieldFox,'SYST:ERR?\n');
initErrCheck = fscanf(fieldFox,'%c')
% Set Instrument and various other important items
% Instrument mode to Network Analyzer
fprintf(fieldFox,'INST:SEL ''NA''')
% Trigger mode to continuous off
fprintf(fieldFox,'INIT:CONT 0\n')
% Set start and stop frequencies. DUT is a wideband 177MHz bandpass
%filter (BPF).
fprintf(fieldFox,'FREQ:STAR 30000;STOP 100000\n')
% Set number of trace points
fprintf(fieldFox,'SWE:POIN 5000\n')
% Trace 1 to measurement of S21 and select that measurement as active
fprintf(fieldFox,'CALC:PAR1:DEF S21;SEL\n')
% Hold off for operation complete to ensure settings
fprintf(fieldFox,'*OPC?\n')
done = fscanf(fieldFox,'%1d')
% Trigger single sweep with hold off via *OPC? Operation Complete Query.
% For long sweeps times there may be a TCPIP hold off or time out setting
%that
% must be increased.
fprintf(fieldFox,'INIT;*OPC?\n')
trigComplete = fscanf(fieldFox,'%1d')
%Query FORMATTED data from fieldFox
% Set data format to real-32 bin block transfer
fprintf(fieldFox, 'FORM:DATA REAL,32\n')
fprintf(fieldFox,'CALC:DATA:FDATA?\n')
myBinData = binblockread(fieldFox,'float')
% There will be a line feed not read, i.e. hanging. Read it to clear
%buffer.
% If you do not read the hanging line feed a -410, "Query Interrupted
% Error" will occur
hangLineFeed = fread(fieldFox,1);

fprintf(fieldFox, 'FORM:DATA REAL,64\n')
fprintf(fieldFox,'SENS:FREQ:DATA?\n')
myBinStimulusData = binblockread(fieldFox,'double')
% There will be a line feed not read, i.e. hanging. Read it to clear
%buffer.
hangLineFeed = fread(fieldFox,1)
% Within the MatLab GUI display data and stimulus numbers and plot same
display myBinData
display myBinStimulusData
% MatLab plot related commands and efforts:
% Convert FieldFox returned frequency data to units of MHz
myStimulusDataMHz = myBinStimulusData
clear title xlabel ylabel
plot(myStimulusDataMHz, myBinData)
xlabel('Frequency (MHz)')
ylabel ('Log Mag (dB)')
% Check Error Queue. A "*CLS" was asserted at the beginning of the
% application. This will clear the entire error queue. Upon completion of
% the application the error queue is queried a final time. If the
% application is written correctly and there are no hardware failures the
% final error query check via 'SYST:ERR?' should return '0, "No Error" else
% the application is in error.
fprintf(fieldFox, 'SYST:ERR?')
finalErrCheck = fscanf(fieldFox, '%c')