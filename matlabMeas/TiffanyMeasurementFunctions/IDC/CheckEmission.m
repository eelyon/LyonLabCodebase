timeBetweenPoints = 0.05;
repeat = 5;


% STM scan, pinch off
%% After Emission     
start = sigDACQueryVoltage(DAC,19);  % Emitter STM at 0
deltaParam = -0.05;
stop = -0.5;
configName = 'afterEmit';
sweep1DMeasDUALSR830('ST',start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC,VmeasE},DAC,{StmCPort,StmEPort},1,configName);

%% single VmeasC
   
start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.01;
stop = start-0.15;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);

start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.01;
stop = -0.1;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);


%% single VmeasE
start = 0;
deltaParam = 0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);

start = -1.5;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,repeat,{VmeasE},DAC,{9},0);


%% DoorE Sweep
start = sigDACQueryVoltage(DAC,23);
deltaParam = -0.1;
stop =-0.2;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{23},0);

%% DoorC Sweep
start = sigDACQueryVoltage(DAC,21);
%start = 0;
deltaParam = 0.02;
stop = -1.3;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{21},0);


%% TFE Sweep
start = sigDACQueryVoltage(DAC,1);
%start = 0;
deltaParam = 0.02;
stop = 0.8;
sweep1DMeasSR830({'TFE'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{1},0);


%% TFC Sweep
start = sigDACQueryVoltage(DAC,3);
%start = 0;
deltaParam = 0.02;
stop = -0.3;
sweep1DMeasSR830({'TFC'},start,stop,deltaParam,timeBetweenPoints,5,{VmeasC},DAC,{3},0);

%% IDC Sweep
start = 0;
deltaParam = 5;
stop = 20;
timeBetweenPoints = 1;
sweep1DMeasSR830({'IDC'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},IDC,{4},0); % in setval, made so that both ch 4,5 are set

%% TopE Sweep
start = -1.2;
deltaParam = 0.02;
stop = -0.7;
timeBetweenPoints = 0.05;
repeat = 5;
sweep1DMeasSR830({'TE'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{14},0); 

%% Sense Sweep
start = 0;
deltaParam = 0.025;
stop = -0.7;
timeBetweenPoints = 0.05;
repeat = 5;
sweep1DMeasSR830({'TE'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{16},1); 

start = 0;
deltaParam = 0.025;
stop = -0.5;
timeBetweenPoints = 0.1;
repeat = 5;
sweep1DMeasSR830({'TE'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{24},0); 



start = 0;
deltaParam = 0.025;
stop = -0.4;
timeBetweenPoints = 0.05;
repeat = 5;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{17},1); 
