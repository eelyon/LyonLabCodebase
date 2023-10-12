%% Transfer Test

closedVoltE = -2;
closedVoltC = -4;
calVoltE = calibratedAP24Volt([DoorEInPort,TwiddleEPort,SenseEPort],[closedVoltE,closedVoltE,closedVoltE]);
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[closedVoltC,closedVoltC,closedVoltC]);

% have twiddle sense area wholly negative before transferring
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort],calVoltE,10000);
pause(1)
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],calVoltC,10000);

DCConfigDAC(DAC,'Transfer',10000);
pause(10)

% open everything in twiddle sense area
openVoltE = 0;
openVoltC = 0.7;
calVoltE = calibratedAP24Volt([DoorEInPort,TwiddleEPort,SenseEPort],[openVoltE,openVoltE,openVoltE]);
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[openVoltC,openVoltC,openVoltC]);
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort],[calVoltE,calVoltE,calVoltE],10000);
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],[calVoltC,calVoltC,calVoltC],10000);


% sweep doorE close open
start = sigDACQueryVoltage(DAC,DoorEClosePort);
deltaParam = 0.02;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);


openVoltC = 0.7;
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[openVoltC,openVoltC,openVoltC]);
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],[calVoltC,calVoltC,calVoltC],10000);

openVoltC = 0;
calVoltC = calibratedAP24Volt([11,16],[openVoltC,openVoltC]);
sigDACRampVoltage(DAC,[11,16],[calVoltC,calVoltC],10000);