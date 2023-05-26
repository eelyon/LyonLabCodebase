sweepType = 'ST';
timeBetweenPoints = 0.05;
repeat = 5;
readSR830 = {VmeasC,VmeasE};
device = DAC;
ports = {StmCPort,StmEPort};
doBackAndForth = 1;

% STM scan, pinch off
%% After Emission     
start = sigDACQueryVoltage(DAC,16);  % Emitter STM at 0
deltaParam = -0.02;
stop = 0.2;
configName = 'afterEmission';
sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);

%% single VmeasC
   
start = sigDACQueryVoltage(DAC,20);
deltaParam = 0.1;
stop = -2;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},0);


%% single VmeasE
%start = sigDACQueryVoltage(DAC,16);
start = 0;
deltaParam = -0.025;
stop = -0.2;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);


%% DoorSweep
start = sigDACQueryVoltage(DAC,23);
%start = 0;
deltaParam = 0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{23},0);


%% TFE Sweep
start = sigDACQueryVoltage(DAC,1);
%start = 0;
deltaParam = -0.05;
stop = -0.5;
sweep1DMeasSR830({'TFE'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{1},0);


%% TFC Sweep
start = sigDACQueryVoltage(DAC,3);
%start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'TFC'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{3},0);
