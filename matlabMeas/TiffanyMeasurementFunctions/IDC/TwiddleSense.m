%% Twiddle Sense Measurement

closedVoltE = -2;
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
% check emission
start = 0;
deltaParam = -0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);


sweep1DMeasSR830Fast({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1)


% lower twiddle and sense back to 0
openVoltE = 0;
calVoltE = calibratedAP24Volt([TwiddleEPort,SenseEPort],[openVoltE,openVoltE]);
sigDACRampVoltage(DAC,[TwiddleEPort,SenseEPort],[calVoltE,calVoltE],10000);

% lower door in modulation 
doorVolt = -0.1;
calVolt = calibratedAP24Volt(DoorEInPort,doorVolt);
sigDACRampVoltage(DAC,DoorEInPort,calVolt,10000);


% increase twiddle amplitude 
twiddleAmp = 0.6/2;
set33220Amplitude(VpulsAgi,twiddleAmp,'VRMS');
set33220Amplitude(VpulsAgi2,twiddleAmp,'VRMS');

% clean off electrons
closedVoltE = -1;
calVoltE = calibratedAP24Volt([TwiddleEPort,SenseEPort],[closedVoltE,closedVoltE]);
sigDACRampVoltage(DAC,[TwiddleEPort,SenseEPort],calVoltE,10000);


% scan while making doorE In more positive, letting electrons in 
start = sigDACQueryVoltage(DAC,DoorEInPort);
deltaParam = 0.02;
stop = 1e-4;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEInPort},0);

%% ST method
% pull electrons
closedVoltE = 0.2;
calVoltE = calibratedAP24Volt([DoorEClosePort,TwiddleEPort,SenseEPort],[closedVoltE,closedVoltE,closedVoltE]);
sigDACRampVoltage(DAC,[DoorEClosePort,TwiddleEPort,SenseEPort],calVoltE,10000);

start = -0.2;
deltaParam = -0.05;
stop = -0.6;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{24},0);

% open collector
closedVoltC = 1.1;
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[closedVoltC,closedVoltC,closedVoltC]);
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],calVoltC,10000);



%% ST with small channels
start = 0.3;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{16},0);

start = 0;
deltaParam = -0.05;
stop = -0.7;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{17},0);

%% Twiddle Check
start = -1;
deltaParam = -0.05;
stop = 0.1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0);

start = -2;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{16},0);

start = 0;
deltaParam = -0.05;
stop = -2;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{17},0);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{16},0);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{17},0);


