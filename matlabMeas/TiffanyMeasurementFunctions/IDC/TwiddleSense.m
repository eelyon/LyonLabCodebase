%% Twiddle Sense Measurement

closedVoltE = -1;
closedVoltC = -4;
calVoltE = calibratedAP24Volt([DoorEInPort,TwiddleEPort,SenseEPort],[closedVoltE,closedVoltE,closedVoltE]);
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[closedVoltC,closedVoltC,closedVoltC]);

% have twiddle sense area wholly negative before emitting
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort],calVoltE,10000);
pause(1)
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],calVoltC,10000);

DCConfigDAC(DAC,'Emitting',10000);
pause(11)

%% EMIT

% lower twiddle and sense back to 0
openVoltE = 0;
calVoltE = calibratedAP24Volt([TwiddleEPort,SenseEPort],[openVoltE,openVoltE]);
sigDACRampVoltage(DAC,[TwiddleEPort,SenseEPort],[calVoltE,calVoltE],10000);

% scan while making doorE In more positive, letting electrons in 
start = sigDACQueryVoltage(DAC,DoorEInPort);
deltaParam = 0.02;
stop = 1e-4;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEInPort},0);

% get electrons off