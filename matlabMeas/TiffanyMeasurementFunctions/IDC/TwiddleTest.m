%% Test Twiddle Sense

start = 50e-3;
stop = 150e-3;
deltaParam = 50e-3;
timeBetweenPoints = 5;
repeat = 30;

sweep1DMeasSR830({'Amp'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},{VtwiddleE,VdoorModE,VmeasC},{1},1)

%% Begin emitting electrons
DCConfigDAC(DAC,'Emitting',1000)
sigDACSetVoltage(DAC,5,-1.3);

closedVoltE = 0;
closedVoltC = 1;
calVoltE = calibratedAP24Volt([DoorEInPort,TwiddleEPort,SenseEPort],[closedVoltE,closedVoltE,closedVoltE]);
calVoltC = calibratedAP24Volt([DoorCInPort,TwiddleCPort,SenseCPort],[closedVoltC,closedVoltC,closedVoltC]);

% have twiddle sense area wholly negative before emitting
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort],calVoltE,10000);
pause(1)
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],calVoltC,10000);

%% EMIT
send33220Trigger(Filament);

% check emission
start = 0;
deltaParam = -0.02;
stop = -0.25;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);

%% lower twiddle and sense to 0
start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{17},0);
pause(3)
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{16},0);
pause(3)

%% do Zero electron test: Test Twiddle Sense
start = 50e-3;
stop = 250e-3;
deltaParam = 50e-3;
timeBetweenPoints = 5;
repeat = 30;

sweep1DMeasSR830({'Amp'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},{VtwiddleE,VdoorModE,VmeasC},{1},1)


set33220Output(VtwiddleE,'ON');
set33220Output(VdoorModE,'ON');

%% lower door 
start = 0.3;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0);  % want to see affect on ST actually


start = 0.2;
deltaParam = -0.1;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,5,5,{VmeasC},DAC,{9},0);

pause(5)

%% raise door back up 
start = 0.1;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0); 

%% Test Twiddle Sense

set33220Output(VtwiddleE,'OFF');
set33220Output(VdoorModE,'OFF');

start = 100e-3;
stop = 500e-3;
deltaParam = 100e-3;
timeBetweenPoints = 5;
repeat = 30;

sweep1DMeasSR830({'Amp'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},{VtwiddleE,VdoorModE,VmeasC},{1},1)

%% get zero measurement again for sanity check: look at ST to see current change hopefully
start = -2;
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
stop = -2;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{9},0); 

start = -0.7;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{17},0);
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{16},0);

%%%%%%%%%%%%%%%%%

amplitudes = [0.2 0.25 0.1 0.05 0.3];

for i=amplitudes
    set33220Output(VdoorModE,0);  % turn off 
    set33220Output(VtwiddleE,0);
    
    sigDACRampVoltage(DAC,9,0,10000);
    pause(10)
    sigDACRampVoltage(DAC,[16,17],[-0.65,-0.65],10000);
    pause(5)
    
    sigDACRampVoltage(DAC,9,-0.65,10000);
    pause(2)
    sigDACRampVoltage(DAC,[16,17],[0,0],10000);
    pause(5)
    
    i = 0.15;
    set33220Amplitude(VdoorModE,i,'VRMS');
    set33220Amplitude(VtwiddleE,i,'VRMS');
    SR830setAmplitude(VmeasC,i);
    
    set33220Output(VdoorModE,1);  % turn on
    set33220Output(VtwiddleE,1);
    pause(5)

    start = 0;
    deltaParam = -0.05;
    stop = -0.5;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,10,5,{VmeasC},DAC,{17},1);


    start = -0.65;
    deltaParam = -0.05;
    stop = 0.2;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,5,5,{VmeasC},DAC,{9},0);

    start = 0.2;
    deltaParam = -0.05;
    stop = -0.65;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,5,5,{VmeasC},DAC,{9},0);


    pause(5)

    set33220Output(VdoorModE,1);  % turn on
    set33220Output(VtwiddleE,1);
    pause(5)
    
    start = 0;
    deltaParam = -0.05;
    stop = -0.5;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,3,5,{VmeasC},DAC,{17},1);

    start = -1;
    deltaParam = -0.1;
    stop = 0;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,5,5,{VmeasC},DAC,{17},0);

end


set33220Output(VdoorModE,0);  % turn off 
set33220Output(VtwiddleE,0);

DCConfigDAC(DAC,'Transferring1',10000);
pause(10)
DCConfigDAC(DAC,'Transferring2',10000);
pause(10)
DCConfigDAC(DAC,'Transfer',10000);
pause(10)

% check electrons

start = 0;
deltaParam = -0.05;
stop = -0.5;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,3,5,{VmeasC},DAC,{17},1);

set33220Output(VdoorModE,1);  % turn on
set33220Output(VtwiddleE,1);

start = -0.65;
deltaParam = -0.05;
stop = 0.2;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,5,5,{VmeasC},DAC,{9},0);

start = 0;
deltaParam = -0.05;
stop = -0.5;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,5,5,{VmeasC},DAC,{17},1);


set33220Output(VdoorModE,0);  % turn off 
set33220Output(VtwiddleE,0);
    

start = -1;
deltaParam = -0.1;
stop = -0.1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,3,5,{VmeasC},DAC,{23},0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clean
sigDACRampVoltage(DAC,5,8,10000);
DCConfigDAC(DAC,'Zero',1000);
pause(1)
sigDACRampVoltage(DAC,5,-1,10000);
DCConfigDAC(DAC,'Emitting',1000);
pause(1)

send33220Trigger(Filament);

%%% rough STM Emitter Scan
start = 0;
deltaParam = -0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);

n = 2;
for i=1:n
    %% Transfer Config
    %%% STM Emitter Scan after transfer config
    start = 0;
    deltaParam = -0.02;
    stop = -0.35;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% Transfer
    %%% open Emitter door scan
    start = sigDACQueryVoltage(DAC,23);
    deltaParam = -0.1;
    stop = -0.3;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{23},1);
    
    %%% STM Collector Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.01;
    stop = start-0.1;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);

    %%% STM Emitter Scan after transfer
    start = 0;
    deltaParam = -0.02;
    stop = -0.35;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% Transfer Back
    DCConfigDAC(DAC,'TransferringBack',10000); pause(10)
    DCConfigDAC(DAC,'TransferBack1',10000); pause(10)
    DCConfigDAC(DAC,'TransferBack2',10000); pause(10)
    
    %%% DoorC Sweep
    start = sigDACQueryVoltage(DAC,21);
    deltaParam = 0.05;
    stop = -0.8;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{21},0);
    
    %%% STM Emitter Scan after transfer back config
    start = 0;
    deltaParam = -0.02;
    stop = -0.35;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %%% STM Collector Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.01;
    stop = start-0.1;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);
    
    sigDACRampVoltage(DAC,22,-1.9,10000);
    pause(1)
    sigDACRampVoltage(DAC,20,-1.9,10000);
    pause(1)
    sigDACRampVoltage(DAC,2,-1.9,10000);
    pause(2)
    
    sigDACRampVoltage(DAC,[22,20,2],-1.7,10000);
    pause(3)
    
    %% After Deep Clean
    %%% STM Collector Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.01;
    stop = start-0.1;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);

    %%% Close door E back 
    sigDACRampVoltage(DAC,23,-1,10000);
    pause(1)
    
    %%% final STM E scan
    start = 0;
    deltaParam = -0.025;
    stop = -0.4;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    pause(2)

    DCConfigDAC(DAC,'Transferring1',5000); pause(6)
    DCConfigDAC(DAC,'Transferring2',5000); pause(6)
    DCConfigDAC(DAC,'Transfer',10000); pause(11)
end