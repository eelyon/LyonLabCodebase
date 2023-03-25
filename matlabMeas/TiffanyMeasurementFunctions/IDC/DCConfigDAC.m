function [ ] = DCConfigDAC( DAC, Command, numSteps )
%   ramps all the device ports to a voltage given a command

TopVoltage = 0;
DCMap;

if strcmp(Command,'Emitting')

    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -4;
    DoorEOpen  = -4;
    %% Collector    
    STOBiasC   = -4;
    STIBiasC   = -4;
    TopC       = STIBiasC-1;
    StmC       = STIBiasC;
    DoorCClose = -5;
    DoorCOpen  = -5;
    %% Thin Film
    TfC        = -2.75;
    TfE        = -2.75;
    %% IDC
    IdcNF      = -2.75;
    IdcPF      = -2.75;

elseif strcmp(Command,'Transferring')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -5;
    DoorEOpen  = -4;
    %% Collector   
    STOBiasC   = 0.75;
    STIBiasC   = 0.75;
    TopC       = -0.03;
    StmC       = STIBiasC;
    DoorCClose = -5;
    DoorCOpen  = -4;
    %% Thin Film
    TfC        = -2.75;
    TfE        = -2.75;
    %% IDC
    IdcNF      = -2.75;
    IdcPF      = -2.75;

elseif strcmp(Command,'Transfer')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -5;
    DoorEOpen  = 0.5;
    %% Collector   
    STOBiasC   = 0.75;
    STIBiasC   = 0.75;
    TopC       = 0.04;
    StmC       = STIBiasC;
    DoorCClose = -5;
    DoorCOpen  = STIBiasC+0.1;
    %% Thin Film
    TfC        = 0.5;
    TfE        = 0.2;
    %% IDC
    IdcNF      = -0.75;
    IdcPF      = -0.75;

elseif strcmp(Command,'TransferringBack')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -5;
    DoorEOpen  = 0.1;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = -1.5;
    TopC       = -2.3;
    StmC       = STIBiasC;
    DoorCClose = -5;
    DoorCOpen  = -0.1;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3.75;
    IdcPF      = -3.75;

elseif strcmp(Command,'TransferBack')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -5;
    DoorEOpen  = 0.1;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = -1.5;
    TopC       = -2.3;
    StmC       = STIBiasC;
    DoorCClose = -5;
    DoorCOpen  = -0.5;
    %% Thin Film
    TfC        = -0.2;
    TfE        = 0.2;
    %% IDC
    IdcNF      = -0.75;
    IdcPF      = -0.75;

 elseif strcmp(Command,'Zero')
    %% Emitter    
    TopE       = 0;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = 0;
    DoorEOpen  = 0;
    %% Collector    
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = 0;
    StmC       = 0;
    DoorCClose = 0;
    DoorCOpen  = 0;
    %% Thin Film
    TfC        = 0;
    TfE        = 0;
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;

 elseif strcmp(Command,'Clean')
    %% Emitter    
    TopE       = 2;
    StmE       = -5;
    STOBiasE   = -5;
    STIBiasE   = -5;
    DoorEClose = -5;
    DoorEOpen  = -5;
    %% Collector    
    STOBiasC   = -5;
    STIBiasC   = -5;
    TopC       = 2;
    StmC       = -5;
    DoorCClose = -5;
    DoorCOpen  = -5;
    %% Thin Film
    TfC        = -5;
    TfE        = -5;
    %% IDC
    IdcNF      = -5;
    IdcPF      = -5;
    
end

% RAMP
chanList = [TopEPort StmEPort STOBiasEPort STIBiasEPort DoorEClosePort DoorEOpenPort STOBiasCPort STIBiasCPort TopCPort StmCPort... 
    DoorCClosePort DoorCOpenPort TfCPort TfEPort IdcNFPort IdcPFPort];
voltList = [TopE StmE STOBiasE STIBiasE DoorEClose DoorEOpen STOBiasC STIBiasC TopC StmC DoorCClose DoorCOpen TfC TfE... 
    IdcNF IdcPF]; 

sigDACRampVoltage(DAC,chanList,voltList,numSteps);

end 