%% This script looks time of flight for different thin film voltages

tStart = tic;
wait = 15;
numTrig = 3;

sweepType = 'ST';
timeBetweenPoints = 0.5;
repeat = 5;
readSR830 = {VmeasC,VmeasE};
device = DAC;
ports = {StmCPort,StmEPort};
doBackAndForth = 1;

% thin film delta 0.3 from [-0.5 -0.1 0 0.1 0.3 0.5 0.75 1] 
thinE = [0.6 0.4 0.35 0.2 0.1 -0.025 -0.15];
thinC = [0.1 0.3 0.35 0.5 0.6 0.725 0.85];


for i = 1:length(thinE) 
    TauE = 5000; % minimum TauE found from CharacterizeDoorETime.m experiment
    for TauC = 2000:1000:4000    
        sigDACRampVoltage(DAC,DoorCClosePort,0.85,1000);  % quick visual check that there aren't electrons already outside collector door
        pause(5)
        sigDACRampVoltage(DAC,DoorCClosePort,-5,1000);
        pause(5)

        sigDACRampVoltage(DAC,[TfEPort,TfCPort],[thinE(i),thinC(i)],10000);  % change TF delta
        pause(10)

        % open door
        doorAWG(VpulsSig,VpulsAgi,TauE,TauC,0,'us')
        pause(5)
        set33220Trigger(VpulsAgi,'BUS');  % to open the doors
        pause(1)
    
        % STM scan, pinch off
        %% AfterTauE
        deltaParam = -0.025;
        stop = -0.4;
        configName = 'AfterTaueE';
        sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
        pause(wait);
    
        % Transferring Back electrons to emitter
        DCConfigDAC_ST(DAC,'TransferringBack',10000);
        pause(wait)
        DCConfigDAC_ST(DAC,'TransferBack',10000);
        pause(wait)
        
        % open door to transfer back electrons to emitter 
        doorAWG(VpulsSig,VpulsAgi,5,1,0,'ms')
        pause(5)
        
        for i = 1:numTrig
            set33220Trigger(VpulsAgi,'BUS');  % to open the doors
            pause(1)
        end
        pause(wait)
        
        sigDACRampVoltage(DAC,18,-1.7,10000);
        pause(wait)
        for i = 1:numTrig-1
            set33220Trigger(VpulsAgi,'BUS');  % to open the doors
            pause(1)
        end
        
        % STM scan, pinch off
        %% AfterTransferBack
        deltaParam = -0.05;
        stop = -0.5;
        configName = 'AfterTransferBack';
        sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
        
        % Transferring electrons
        DCConfigDAC_ST(DAC,'Transferring',10000);
        pause(wait);
        DCConfigDAC_ST(DAC,'Transfer',10000);
        pause(wait);
        
        % final STM scan, pinch off
        %% AfterTransferring
        deltaParam = -0.025;
        stop = -0.4;
        configName = 'AfterTransferring';
        sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
        pause(wait);
    end
end

tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));

