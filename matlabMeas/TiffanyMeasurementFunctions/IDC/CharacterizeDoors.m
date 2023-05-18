%% This script characterizes the door opening voltage of the emitter

doorE = 1;
doorC = 0;

% Characterize emitter door opening to collector
if doorE
    doorEOpen = [-4 -2 -0.5 -0.1 0 0.1:0.1:0.3];
    doorAWG(VpulsSig,VpulsAgi,1,5,0,'ms'); 
    pause(1)
    
    for doorVolt = doorEOpen
        sigDACRampVoltage(DAC,DoorEOpenPort,doorVolt,10000);
        pause(10);
        %set33220Trigger(VpulsAgi,'BUS');
        send33220Trigger(VpulsAgi);
        pause(3);
    
        % ST measurement after opening doors
        sweepType = 'ST';
        
        start = sigDACQueryVoltage(DAC,16);
        deltaParam = -0.05;
        stop = -0.3;
    
        timeBetweenPoints = 0.05;
        repeat = 5;
        readSR830 = {VmeasC,VmeasE};
        device = DAC;
        ports = {StmCPort,StmEPort};
        doBackAndForth = 1;
        configName = 'doorESweep';
        sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
        pause(0.1)
    end

% Characterize collector door opening to accept from emitter
else
    numTrig = 3;
    % Transferring Back electrons to emitter
    DCConfigDAC_ST(DAC,'TransferringBack',10000);
    pause(wait)
    DCConfigDAC_ST(DAC,'TransferBack',10000);
    pause(wait)
    
    doorAWG(VpulsSig,VpulsAgi,5,1,0,'ms')
    pause(5)
    
    for i = 1:numTrig
        set33220Trigger(VpulsAgi,'BUS');  % to open the doors
        pause(1)
    end
    
    sigDACRampVoltage(DAC,18,-1.7,10000);
    pause(wait)
    
    % open door to transfer back electrons to emitter 
    for i = 1:numTrig
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

    doorCOpen = [-5 -3 -1 -0.5 0 0.1 0.2];
    doorAWG(VpulsSig,VpulsAgi,500,100,0,'ms') 
    pause(1)
    
    for doorVolt = doorCOpen
        sigDACRampVoltage(DAC,DoorCOpenPort,doorVolt,10000);
        pause(10);
        set33220Trigger(VpulsAgi,'BUS');
        pause(3);
    
        % ST measurement after opening doors
        sweepType = 'ST';
        
        start = sigDACQueryVoltage(DAC,16);
        deltaParam = -0.05;
        stop = -0.5;
    
        timeBetweenPoints = 0.5;
        repeat = 5;
        readSR830 = {VmeasC,VmeasE};
        device = DAC;
        ports = {StmCPort,StmEPort};
        doBackAndForth = 1;
        configName = 'doorCSweep';
        sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
        pause(0.1)
    end
end