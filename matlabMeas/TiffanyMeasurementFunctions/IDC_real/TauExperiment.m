%% Paramters
Tau             = 900;
TauUnit         = 'us';
PulseWidth      = 100;
PulseWidthUnit  = 'us';
BiasLow         = 5;
biasHigh        = -5;
VclosedC         = -1.5;
VopenC           = -0.94;
VTop            = -1.5;
VIDCNTau        = -10;
VIDCPTau        = -5;
VTopMetal       = -5;


%% Initiialize
fprintf(Vpuls,['PULS:PER' ' ' num2str(Tau) ' ' TauUnit]);
fprintf(Vpuls,['PULS:WIDT' ' ' num2str(PulseWidth) ' ' PulseWidthUnit])
VclosedE         = VclosedC;
VopenE           = VopenC;
DCConfigsTau

%% Run
    Extra = 'PreEmission';
    CheckDensities
    
    %Flash Filament
    input('Flashed?:\n')
    
    Extra = 'Postemission';
    CheckDensities
    
    biasC           = BiasLow;
    VIDCPTau        = 0;
    DCConfigsTau
    
    Extra = 'VoltagesSweptToTransfer';
    CheckDensities
    
    %Open Doors
    for i = 1:NumberFlushes
        Extra = ['Tau_' num2str(Tau)];
        fprintf(Vpuls,'TRIG')
        
        biasC           = BiasHigh;
        DCConfigsTau
        
        EmitterDoorSweepTau;
    
        
    
    %OpenClose Emitter
    Extra = 'OpeningEmitter';
    doorControl = 'OpenClose';
    EmitterDoorSweep
    
    Extra = 'CheckingIfElectronsTransferred';
    CheckDensities
    

