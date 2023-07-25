%% Test Twiddle Sense

start = 10e-3;
stop = 50e-3;
deltaParam = 10e-3;
timeBetweenPoints = 5;
repeat = 30;

sweep1DMeasSR830({'Amp'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},{VtwiddleE,VdoorModE,VmeasC},{1},1)

%% Begin emitting electrons
DCConfigDAC(DAC,'Emitting',1000)
sigDACSetVoltage(DAC,5,-1.3);

closedVoltE = -2;
closedVoltC = -4;
calVoltE = calibratedAP24Volt([DoorEInPort,TwiddleEPort,SenseEPort],[closedVoltE,closedVoltE,closedVoltE]);
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[closedVoltC,closedVoltC,closedVoltC]);

% have twiddle sense area wholly negative before emitting
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort],calVoltE,10000);
pause(1)
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],calVoltC,10000);

% check emission
start = 0;
deltaParam = -0.02;
stop = -0.25;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);

%% lower twiddle and sense to 0
start = -2;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{17},0);

start = -2;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{16},0);

%% do Zero electron test:  Test Twiddle Sense

start = 100e-3;
stop = 500e-3;
deltaParam = 100e-3;
timeBetweenPoints = 5;
repeat = 30;

sweepTwiddleSense({'Amp'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},{VtwiddleE,VdoorModE,VmeasC},{1},1)

%% lower door 
start = -2;
deltaParam = -0.05;
stop = 0.3;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0);  % want to see affect on ST actually

%% raise door back up 
start = 0.3;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0); 

%% Test Twiddle Sense

start = 100e-3;
stop = 500e-3;
deltaParam = 100e-3;
timeBetweenPoints = 5;
repeat = 30;

sweepTwiddleSense({'Amp'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},{VtwiddleE,VdoorModE,VmeasC},{1},1)

%% get zero measurement again for sanity check: look at ST to see current change hopefully
start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0); 

start = 0;
deltaParam = -0.05;
stop = -0.7;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{17},0);
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{16},0);

start = -0.7;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{17},0);
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{16},0);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0); 

start = -1.3;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{17},0);
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{16},0);





