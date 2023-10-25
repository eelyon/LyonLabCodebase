%% Transfer Measurement Procedure

% emit electrons and measure
DCConfigDAC(DAC,'Emitting',10000);
pause(10);

start = 0;
deltaParam = 0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

n = [10 8 6 5 10 7 9]; % TauC scan
% n = [0.01 0.1 1 10 100 100 10 1 0.1 0.01];  TauE scan

for i = n
    % Transfer
    DCConfigDAC(DAC,'Transferring1',10000);
    pause(10)
    
    DCConfigDAC(DAC,'Transferring2',10000);
    pause(10)
    
    DCConfigDAC(DAC,'Transfer',10000);
    pause(10)

    SR830setAmplitude(VmeasE,0.004)

    % Door Sweep
    % doorAgi(VpulsAgi,VpulsAgi2,i,1000,'ms');
    % doorAgi(VpulsAgi,VpulsAgi2,100,10,'us');
    doorAgi(VpulsAgi,VpulsAgi2,100,i,'us');

    send33220Trigger(VpulsAgi);
    
    SR830setAmplitude(VmeasE,0.1)

    % After transfer sweeps
    start = 1; %sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.01;
    stop = start-0.1;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);
    
    start = 0;
    deltaParam = 0.02;
    stop = -0.6;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
    
    % Transfer Back
    DCConfigDAC(DAC,'TransferringBack',10000);
    pause(10)
    
    DCConfigDAC(DAC,'TransferBack1',10000);
    pause(10)
    
    DCConfigDAC(DAC,'TransferBack2',10000);
    pause(10)
    
    SR830setAmplitude(VmeasC,0.004)

    sigDACRampVoltage(DAC,DoorCClosePort,-0.6,1000)
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
    stop = -0.6;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
end
