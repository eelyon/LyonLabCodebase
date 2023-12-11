%% Transfer Measurement Procedure

times = [800 600 550 500 575 800];

for i = times

    % Transfer
    DCConfigDAC(DAC,'Transferring1',8000);
    pause(9)
    
    DCConfigDAC(DAC,'Transferring2',8000);
    pause(9)
    
    DCConfigDAC(DAC,'Transfer',8000);
    pause(9)
    
    SR830setAmplitude(VmeasE,0.004)
    pause(1)
    SR830setAmplitude(VmeasC,0.004)
    pause(1)
    sigDACRampVoltage(DAC,STOBiasEPort,-0.15,1000)
    
    % Door Sweep
    doorAgi(VpulsAgi,VpulsAgi2,1000,i,'ms');
    pause(1)
    send33220Trigger(VpulsAgi);
    pause(3)
    
    sigDACRampVoltage(DAC,STOBiasEPort,0,1000)
    SR830setAmplitude(VmeasE,0.1)
    pause(1)
    SR830setAmplitude(VmeasC,0.1)
    pause(1)
    
    % After transfer sweeps
    start = 1; %sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.01;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{StmCPort},1);
    
    start = 0;
    deltaParam = 0.02;
    stop = -0.3;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
    
    % Transfer Back
    DCConfigDAC(DAC,'TransferringBack',8000);
    pause(9)
    
    DCConfigDAC(DAC,'TransferBack1',8000);
    pause(9)
    
    DCConfigDAC(DAC,'TransferBack2',8000);
    pause(9)
    
    start = sigDACQueryVoltage(DAC,DoorCClosePort);
    deltaParam = 0.05;
    stop = -0.8;
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{DoorCClosePort},0);
    
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-1.2,-1.2,-1.2],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-1.1,-1.1,-1.1],1000);
    pause(2)
    
    sigDACRampVoltage(DAC,STOBiasCPort,-1.7,1000)
    pause(7)
    sigDACRampVoltage(DAC,StmCPort,-1.7,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.7,1000)
    pause(1)
    
    sigDACRampVoltage(DAC,STOBiasCPort,-1.8,1000)
    pause(5)
    sigDACRampVoltage(DAC,StmCPort,-1.8,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.8,1000)
    pause(3)
    
    sigDACRampVoltage(DAC,STOBiasCPort,-1.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmCPort,-1.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.5,1000)
    pause(1)
    
    sigDACRampVoltage(DAC,DoorEClosePort,-1,1000)
    
    start = 0;
    deltaParam = 0.02;
    stop = -0.3;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
end