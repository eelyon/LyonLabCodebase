%% Transfer Measurement Procedure

% emit electrons and measure
DCConfigDAC(DAC,'Emitting',10000);
pause(10);

start = 0;
deltaParam = 0.025;
stop = -0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

n = [5000 4000 3500 3000 3750 5000]; % TauC scan
for i = n
    % Transfer
    DCConfigDAC(DAC,'Transferring1',8000);
    pause(9)
    
    DCConfigDAC(DAC,'Transferring2',8000);
    pause(9)
    
    DCConfigDAC(DAC,'Transfer',8000);
    pause(9)

    % SR830setAmplitude(VmeasE,0.004)

    % Door Sweep
    doorAgi(VpulsAgi,VpulsAgi2,5000,i,'us');
    pause(1)
    send33220Trigger(VpulsAgi);
    pause(2)

%     SR830setAmplitude(VmeasE,0.1)
%     SR830setAmplitude(VmeasC,0.1)

    % After transfer sweeps
    start = 1; %sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.005;
    stop = start-0.05;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{StmCPort},1);
    
    start = 0;
    deltaParam = 0.02;
    stop = -0.25;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
    
    % Transfer Back
    DCConfigDAC(DAC,'TransferringBack',8000);
    pause(9)
    
    DCConfigDAC(DAC,'TransferBack1',8000);
    pause(9)
    
    DCConfigDAC(DAC,'TransferBack2',8000);
    pause(9)
    
    SR830setAmplitude(VmeasC,0.004)

    sigDACRampVoltage(DAC,DoorCClosePort,-1,1000)
    pause(10)
    
    sigDACRampVoltage(DAC,STOBiasCPort,-1.7,1000)
    pause(7)
    sigDACRampVoltage(DAC,StmCPort,-1.7,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.7,1000)
    pause(1)

    sigDACRampVoltage(DAC,STOBiasCPort,-1.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmCPort,-1.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.5,1000)
    pause(1)

    SR830setAmplitude(VmeasC,0.1)

    sigDACRampVoltage(DAC,STOBiasCPort,-1.8,1000)
    pause(5)
    sigDACRampVoltage(DAC,StmCPort,-1.8,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.8,1000)
    pause(1)

    sigDACRampVoltage(DAC,STOBiasCPort,-1.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmCPort,-1.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasCPort,-1.5,1000)
    pause(1)
    
    sigDACRampVoltage(DAC,DoorEClosePort,-1,1000)
    pause(1)

    start = 0;
    deltaParam = 0.02;
    stop = -0.25;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
end
