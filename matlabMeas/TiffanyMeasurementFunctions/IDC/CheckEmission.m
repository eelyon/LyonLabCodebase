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
deltaParam = -0.05;
stop = -0.2;
configName = 'afterTransfer';
sweep1DMeasDUALSR830('ST',start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC,VmeasE},DAC,{StmCPort,StmEPort},1,configName);

%% single VmeasC
   
start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.005;
stop = start-0.1;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);


%% single VmeasE
%start = sigDACQueryVoltage(DAC,16);
start = 0;
deltaParam = -0.005;
stop = -0.15;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);


%% DoorE Sweep
start = sigDACQueryVoltage(DAC,23);
%start = 0;
deltaParam = 0.05;
stop = 0.1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{23},0);

%% DoorC Sweep
start = sigDACQueryVoltage(DAC,21);
%start = 0;
deltaParam = 0.05;
stop = -0.6;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{21},0);


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
sweep1DMeasSR830({'TFC'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{3},0);
