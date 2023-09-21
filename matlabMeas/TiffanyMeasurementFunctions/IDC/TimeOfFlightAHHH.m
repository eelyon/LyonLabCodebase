n = [-1 -1.3 -1.5];
for i = n
    %% Transfer Config
    %%% STM Emitter Scan after transfer config
    start = 0;
    deltaParam = -0.025;
    stop = -0.5;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% Transfer
    %%% open Emitter door scan
    start = sigDACQueryVoltage(DAC,23);
    deltaParam = -0.1;
    stop = 1;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{23},0);

    doorAgi(VtwiddleE,VdoorModE,10,1000,'ms');
    set33220Trigger(VtwiddleE,'BUS');  % to open the doors

    %%% STMC Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.025;
    stop = start-0.5;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{20},1);

    %%% STME Scan after transfer
    start = 0;
    deltaParam = -0.02;
    stop = -0.3;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% Transfer Back
    DCConfigDAC(DAC,'TransferringBack',10000); pause(11)
    DCConfigDAC(DAC,'TransferBack1',10000); pause(11)
    DCConfigDAC(DAC,'TransferBack2',10000); pause(11)
    
    sigDACRampVoltage(DAC,[8,12],[n,n],10000);
    pause(1)
    
    %%% DoorC Sweep
    start = sigDACQueryVoltage(DAC,21);
    deltaParam = 0.05;
    stop = -0.7;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{21},0);
    
%     doorAgi(VtwiddleE,VdoorModE,5000,5000,'ms');
%     set33220Trigger(VtwiddleE,'BUS');  % to open the doors
%     pause(1)
%     set33220Trigger(VtwiddleE,'BUS');  % to open the doors

    %%% STM Emitter Scan after transfer back config
    start = 0;
    deltaParam = -0.02;
    stop = -0.4;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %%% STM Collector Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.05;
    stop = start-0.7;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.7,5,{VmeasC},DAC,{20},1);
    
    sigDACRampVoltage(DAC,21,-1.2,10000);  % open doorC close before cleaning!!
    sigDACRampVoltage(DAC,23,0,10000);  % open doorE close before cleaning!!

    sigDACRampVoltage(DAC,22,-1.9,10000);
    pause(1)
    sigDACRampVoltage(DAC,20,-1.9,10000);
    pause(1)
    sigDACRampVoltage(DAC,2,-1.9,10000);
    pause(2)
    
    sigDACRampVoltage(DAC,[22,20,2],-1.5,10000);
    pause(3)
    
    %% After Deep Clean
    %%% STM Collector Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.02;
    stop = start-0.4;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,repeat,{VmeasC},DAC,{20},1);

    %%% Close door E back 
    sigDACRampVoltage(DAC,23,-1,10000);
    pause(1)
    
    %%% final STM E scan
    start = 0;
    deltaParam = -0.03;
    stop = -0.5;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    pause(2)

    DCConfigDAC(DAC,'Transferring1',5000); pause(6)
    DCConfigDAC(DAC,'Transferring2',5000); pause(6)
    DCConfigDAC(DAC,'Transfer',10000); pause(11)
end