times = [10 50 1000 100 50 500 100 500 1000];
for n = times
    DCConfigDAC(DAC,'Transferring1',10000); pause(11)
    DCConfigDAC(DAC,'Transferring2',10000); pause(11)
    DCConfigDAC(DAC,'Transfer',10000); pause(11)
    
    %% STM_E SCAN
    start = 0;
    deltaParam = -0.05;
    stop = -0.5;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    doorAgi(VtwiddleE,VdoorModE,100,0.25,'us');
    set33220Trigger(VtwiddleE,'BUS');  % to open the doors
    pause(1)
    
    %% STM_E Scan
    start = 0;
    deltaParam = -0.025;
    stop = -0.45;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% STM C Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.02;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{20},1);

    DCConfigDAC(DAC,'TransferringBack',10000); pause(11)
    DCConfigDAC(DAC,'TransferBack1',10000); pause(11)
    DCConfigDAC(DAC,'TransferBack2',10000); pause(11)
    
    %% Door C scan
    start = sigDACQueryVoltage(DAC,21);
    deltaParam = 0.05;
    stop = -0.5;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{21},0);
    
    sigDACRampVoltage(DAC,22,-1.7,10000);
    pause(1)
    sigDACRampVoltage(DAC,20,-1.7,10000);
    pause(1)
    sigDACRampVoltage(DAC,2,-1.7,10000);
    pause(2)
    
    sigDACRampVoltage(DAC,22,-1.9,10000);
    pause(1)
    sigDACRampVoltage(DAC,20,-1.9,10000);
    pause(1)
    sigDACRampVoltage(DAC,2,-1.9,10000);
    pause(2)
    
    sigDACRampVoltage(DAC,22,-1.5,10000);
    pause(1)
    sigDACRampVoltage(DAC,20,-1.5,10000);
    pause(1)
    sigDACRampVoltage(DAC,2,-1.5,10000);
    pause(2)
    
    %% STM_E Scan
    start = 0;
    deltaParam = -0.025;
    stop = -0.45;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);
    
    %% STM C Scan
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.025;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{20},1);
end