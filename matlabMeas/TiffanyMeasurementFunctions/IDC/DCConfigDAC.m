function [ ] = DCConfigDAC( DAC, Command, numSteps )
%   ramps all the device ports to a voltage given a command

turnOnHelium = 0;
TopVoltage   = -0.7;
DCMap;

if strcmp(Command,'Emitting')

    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -0.5;
    %% Collector    
    STOBiasC   = -4;
    STIBiasC   = -4;
    TopC       = -4.5;
    StmC       = -4;
    DoorCClose = -4;
    DoorCOpen  = -4;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

elseif strcmp(Command,'Transferring')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 0.1;
    %% Collector   
    STOBiasC   = 1;
    STIBiasC   = 1;
    TopC       = 0.5;
    StmC       = STIBiasC;
    DoorCClose = -3;
    DoorCOpen  = 1;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

elseif strcmp(Command,'Transfer')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 0.1;
    %% Collector   
    STOBiasC   = 1;
    STIBiasC   = STOBiasC;
    TopC       = -0.1;
    StmC       = STOBiasC;
    DoorCClose = -1;
    DoorCOpen  = 1.5;
    %% Thin Film
    TfC        = -0.1;
    TfE        = 0.4;
    %% IDC
    IdcNF      = -2;
    IdcPF      = -2;

elseif strcmp(Command,'TransferringBack')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = 0.2;
    DoorEOpen  = -1;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = -1.5;
    TopC       = -2;
    StmC       = STIBiasC;
    DoorCClose = -5;
    DoorCOpen  = -5;
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
    DoorEClose = 0.2;
    DoorEOpen  = 0.1;
    %% Collector    
    STOBiasC   = -4;
    STIBiasC   = -4;
    TopC       = -4.5;
    StmC       = STIBiasC;
    DoorCClose = -3;
    DoorCOpen  = -0.5;
    %% Thin Film
    TfC        = -1;
    TfE        = 0.3;
    %% IDC
    IdcNF      = -2;
    IdcPF      = -2;

 elseif strcmp(Command,'Flip')

    %% Emitter    
    TopE       = -4;
    StmE       = -3;
    STOBiasE   = -3;
    STIBiasE   = -3;
    DoorEClose = -5;
    DoorEOpen  = -0.5;
    %% Collector    
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = TopVoltage;
    StmC       = 0;
    DoorCClose = -2;
    DoorCOpen  = -2;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

elseif strcmp(Command,'FlipTransfer')

    %% Emitter    
    TopE       = 1.5;
    StmE       = 3;
    STOBiasE   = 3;
    STIBiasE   = 3;
    DoorEClose = -5;
    DoorEOpen  = 1.5;
    %% Collector    
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = TopVoltage;
    StmC       = 0;
    DoorCClose = -4;
    DoorCOpen  = 0.1;
    %% Thin Film
    TfC        = 0.5;
    TfE        = 0.9;
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;

elseif strcmp(Command,'FlipTransfering')

    %% Emitter    
    TopE       = 0;
    StmE       = 3;
    STOBiasE   = 3;
    STIBiasE   = 3;
    DoorEClose = -5;
    DoorEOpen  = 0.8;
    %% Collector    
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = TopVoltage;
    StmC       = 0;
    DoorCClose = -4;
    DoorCOpen  = 0.1;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;
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

if turnOnHelium
   negIDC = 20;
   posIDC = -20;
   devices = {SIM900,SIM900};
   ports = {IdcNFPort,IdcPFPort};
   stop = [negIDC,posIDC];
   numSteps = 100;
   waitTime = 5;

   interleavedRamp(devices,ports,stop,numSteps,waitTime)
end

end 