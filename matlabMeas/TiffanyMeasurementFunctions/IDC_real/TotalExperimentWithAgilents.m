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
    DCConfigs2Tau('Emitting')
    
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
    DCConfigs2Tau('Transfer')
    
%     Extra = 'VoltagesSweptToTransfer';
%     CheckDensities
    
    %Open Collector
    Extra = 'OpeningCollector';
    doorControl = 'Open';
    CollectorDoorSweepTau
    
    Extra = 'CheckingIfElectronsAdded';
    V = 0:-.1:-1;
    CheckDensities
    
    %OpenClose Emitter
    Extra = 'OpeningEmitter';
    doorControl = 'Open';
    EmitterDoorSweepTau
    
    Extra = 'CheckingIfElectronsTransferred';
    V = [0:-.02:-.2 -.3:-.1:-1];
    CheckDensities
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
