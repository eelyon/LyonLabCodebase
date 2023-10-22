DCConfigDAC(DAC,'Emitting',1000)
set33220VoltageOffset(VdoorModE,-1);
set33220VoltageOffset(VtwiddleE,-1);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0,1);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0,1);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},0,1);

start = 0;
deltaParam = -0.02;
stop = -0.4;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,20,{VmeasC},DAC,{17},1);

start = 0;
deltaParam = -0.02;
stop = 0.4;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);


start = 0.1;
deltaParam = -0.02;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},0);



start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{23},0);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Top'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{23},0);





start = -1;
deltaParam = -0.02;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},0);

start = -0.95;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleC,{5},1);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{16},0);


start = -0.3;
deltaParam = -0.025;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,20,{VmeasC},VdoorModE,{5},0);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start = 0;
deltaParam = -0.025;
stop = -0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{4},0);


doorV = [-1:0.1:-0.1 -0.1:-0.1:-1];

for i =1:length(doorV)
    start = doorV(i);
    deltaParam = -0.05;
    stop = doorV(i+1);
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0);
    
    pause(5)

    start = 0;
    deltaParam = -0.02;
    stop = 0.4;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);
    
    pause(5)

    start = 0;
    deltaParam = -0.02;
    stop = 0.4;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
   
start = sigDACQueryVoltage(DAC,StmCPort);
deltaParam = -0.025;
stop = start-0.55;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);

start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.01;
stop = -0.1;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);


%% single VmeasE
start = 3.6; % sigDACQueryVoltage(DAC,StmEPort); % it's because its setting what it's querying, not the actual value
deltaParam = -0.02;
stop = start-0.25;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasE},DAC,{StmEPort},1);

start = 0;
deltaParam = 0.001;
stop = -0.08;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);

start = 0;
deltaParam = 0.05;
stop = -0.8;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);

start = -1.5;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,repeat,{VmeasE},DAC,{9},0);


%% DoorE Sweep
start = sigDACQueryVoltage(DAC,DoorEClosePort);
deltaParam = -0.05;
stop = -3.3;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);

start = sigDACQueryVoltage(DAC,DoorEInPort);
deltaParam = -0.01;
stop = 0.5;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEInPort},0);

start = sigDACQueryVoltage(DAC,DoorEInPort);
deltaParam = -0.01;
stop = 0.7;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEInPort},0);

start = sigDACQueryVoltage(DAC,TwiddleEPort);
deltaParam = -0.01;
stop = 0.7;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{TwiddleEPort},0);

start = sigDACQueryVoltage(DAC,SenseEPort);
deltaParam = -0.01;
stop = 0.25;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{SenseEPort},0);

%% DoorC Sweep
start = sigDACQueryVoltage(DAC,DoorCClosePort);
%start = 0;
deltaParam = 0.05;
stop = -2.5;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{DoorCClosePort},0);


start = sigDACQueryVoltage(DAC,DoorCClosePort);
%start = 0;
deltaParam = 0.05;
stop = 2;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{DoorCClosePort},0);

%% TFE Sweep
start = sigDACQueryVoltage(DAC,1);
%start = 0;
deltaParam = 0.02;
stop = 1.5;
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



