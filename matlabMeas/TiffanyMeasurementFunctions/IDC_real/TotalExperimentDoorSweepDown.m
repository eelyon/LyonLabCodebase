tic
%% Options
EmittingStep   = 1;
normalTransfer = 1;
sloshBack      = 0;


Fullwait = 1;
DCMap;

doorControl = 'Open'


%% Experiment

if EmittingStep
    
    %Voltages for Emission
    DCConfigs2('Emitting')
    
    %Extra = 'PreEmission';
    %CheckDensities
    
    %Flash Filament
    input('Flashed?:\n')
    
    %Extra = 'Postemission';
    %CheckDensities
    
end

if normalTransfer
    %Clean
    %scanType = 'CL';
    %Sweep
    
    
    
    %Voltages for Transfer
    DCConfigs2('Transfer')
    
%     Extra = 'VoltagesSweptToTransfer';
%     CheckDensities
    
    for DoorEVoltage = [[-2 -1 -.9] -.95:.05:-.4 -.3:.15:0]
        Extra = ['DoorNowIsNeg' num2str(abs(DoorEVoltage))];
        V = 0:-.1:-1;

        OpenCollector

        LowerEmitter

        CloseCollector
        
        CheckDensities
    end
    
end

toc
tic

if sloshBack    
    %Voltages for Slosh Back
    DCConfigs2('TransferBack')
    
    Extra = 'VoltagesSweptToTransferBack';
    CheckDensities
    
    %Opening Emitter
    Extra = 'OpeningEmitter';
    doorControl = 'Open';
    EmitterDoorSweep
    
    Extra = 'OpenedEmitterBack';
    CheckDensities
    
    %Opening Collector
    Extra = 'OpeningCollector';
    doorControl = 'OpenClose';
    CollectorDoorSweep
    
    Extra = 'OpenedCollectorBack';
    CheckDensities
    
        
    CloseDoors
    
end
toc
