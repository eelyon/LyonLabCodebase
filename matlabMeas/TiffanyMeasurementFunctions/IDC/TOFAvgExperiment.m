%% This script performs time of flight experiment with repeated averaging for better time of flight measurement

tStart = tic;
wait = 15;
numRepeated = 1;

sweepType = 'ST';
timeBetweenPoints = 0.5;
repeat = 5;
readSR830 = {VmeasC,VmeasE};
device = DAC;
ports = {StmCPort,StmEPort};
doBackAndForth = 1;

TauE = 5000; % minimum TauE found from CharacterizeDoorETime.m experiment
for index = 1:numRepeated
    for TauC = 1000  % less than the time found from TOFExperiment.m    
%         sigDACRampVoltage(DAC,DoorCClosePort,0.85,1000);  % quick visual check that there aren't electrons already outside collector door
%         pause(5)
%         sigDACRampVoltage(DAC,DoorCClosePort,-5,1000);
%         pause(5)
    
        % open door
        doorAWG(VpulsSig,VpulsAgi,TauE,TauC,0,'us')
        pause(5)
        set33220Trigger(VpulsAgi,'BUS');  % to open the doors
        pause(1)
    
        % STM scan, pinch off
        %% AfterTauE
        deltaParam = -0.025;
        stop = -0.4;
        configName = 'AfterTauE';
        sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
        pause(wait);
    
        % Transferring Back electrons to emitter
        DCConfigDAC_ST(DAC,'TransferringBack',10000);
        pause(wait)
        DCConfigDAC_ST(DAC,'TransferBack',10000);
        pause(wait)
        
        % STM scan, pinch off
        %% AfterTransferBack
        deltaParam = -0.05;
        stop = -0.5;
        configName = 'AFterTransferBack';
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

