
n = [10 1 10 20 30 50 80 100 1000 0.1 5 200 0.5 0.01];  % first one doesnt count

for i = n
    DCConfigDAC(DAC,'FlipTransfer1',10000);
    pause(10)
    
    DCConfigDAC(DAC,'FlipTransfer',8000);
    pause(8)
    
    doorAgi(VpulsAgi,VpulsAgi2,10,n,'ms');
    
    start = sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.025;
    stop = start-0.4;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);
    
    start = 3.6; % sigDACQueryVoltage(DAC,StmEPort);
    deltaParam = -0.02;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasE},DAC,{StmEPort},1);
    
    send33220Trigger(VpulsAgi);
    pause(1)
    
    start = sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.025;
    stop = start-0.55;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);
    
    start = 3.6; % sigDACQueryVoltage(DAC,StmEPort);
    deltaParam = -0.02;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasE},DAC,{StmEPort},1);
    
    DCConfigDAC(DAC,'FlipTransferBack1',10000);
    pause(10)
    
    DCConfigDAC(DAC,'FlipTransferBack2',10000);
    pause(10)
    
    DCConfigDAC(DAC,'FlipTransferBack',10000);
    pause(10)
    
    start = sigDACQueryVoltage(DAC,DoorEClosePort);
    deltaParam = -0.05;
    stop = -3;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);
    
    % start = -3.3; % sigDACQueryVoltage(DAC,StmEPort);
    % deltaParam = -0.02;
    % stop = start-0.15;
    % sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasE},DAC,{StmEPort},1);
    
    
    sigDACRampVoltage(DAC,STOBiasEPort,-3.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmEPort,-3.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasEPort,-3.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STOBiasEPort,-3.3,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmEPort,-3.3,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasEPort,-3.3,1000)
    pause(1)
    
    start = sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.025;
    stop = start-0.55;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);

    DCConfigDAC(DAC,'FlipEmit',8000);
    pause(8)
    
    send33220Trigger(VtwiddleC);
end


