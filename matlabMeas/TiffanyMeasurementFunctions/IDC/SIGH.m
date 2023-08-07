% DCConfigDAC(DAC,'Emitting',10000); pause(11)
% send33220Trigger(Filament)

times = [1000 500];
for n = times
    DCConfigDAC(DAC,'Transferring1',5000); pause(6)
    DCConfigDAC(DAC,'Transferring2',5000); pause(6)
    DCConfigDAC(DAC,'Transfer',10000); pause(11)
    
    %% STM_E SCAN
    start = 0;
    deltaParam = -0.025;
    stop = -0.45;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    doorAgi(VtwiddleE,VdoorModE,200,5000,'us');
    pause(1)
    set33220Trigger(VtwiddleE,'BUS');  % to open the doors
    pause(1) 
    
    %% STM C Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.02;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{20},1);

    %% STM_E Scan
    start = 0;
    deltaParam = -0.02;
    stop = -0.4;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    DCConfigDAC(DAC,'TransferringBack',5000); pause(6)
    DCConfigDAC(DAC,'TransferBack1',5000); pause(6)
    DCConfigDAC(DAC,'TransferBack2',5000); pause(6)
    
    %% Door C scan
    start = sigDACQueryVoltage(DAC,21);
    deltaParam = 0.1;
    stop = -0.9;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{21},0);
    
    sigDACRampVoltage(DAC,22,-1.7,10000);
    pause(3)
    sigDACRampVoltage(DAC,20,-1.7,10000);
    pause(3)
    sigDACRampVoltage(DAC,2,-1.7,10000);
    pause(3)
    
    sigDACRampVoltage(DAC,22,-1.8,10000);
    pause(3)
    sigDACRampVoltage(DAC,20,-1.8,10000);
    pause(3)
    sigDACRampVoltage(DAC,2,-1.8,10000);
    pause(3)
    
    sigDACRampVoltage(DAC,22,-1.5,10000);
    pause(3)
    sigDACRampVoltage(DAC,20,-1.5,10000);
    pause(3)
    sigDACRampVoltage(DAC,2,-1.5,10000);
    pause(3)
    
    %% STM_E Scan
%     start = 0;
%     deltaParam = -0.02;
%     stop = -0.4;
%     sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% STM C Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.025;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{20},1);
end
