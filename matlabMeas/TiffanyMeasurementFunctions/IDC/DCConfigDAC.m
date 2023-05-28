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
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC;
    StmC       = STOBiasC;
    DoorCClose = STOBiasC;
    DoorCOpen  = STOBiasC;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

elseif strcmp(Command,'Transferring1')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 0.1;
    %% Collector   
    STOBiasC   = -4;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC;
    StmC       = STOBiasC;
    DoorCClose = STOBiasC;
    DoorCOpen  = STOBiasC;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

elseif strcmp(Command,'Transferring2')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 0.1;
    %% Collector   
    STOBiasC   = 1.5;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC-0.7;
    StmC       = STOBiasC;
    DoorCClose = -0.05;
    DoorCOpen  = TopC-0.2;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

elseif strcmp(Command,'Transfer')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 0.1;
    %% Collector   
    STOBiasC   = 1.5;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC-0.7;
    StmC       = STOBiasC;
    DoorCClose = -0.05;
    DoorCOpen  = TopC-0.2;
    %% Thin Film
    TfC        = 0.6;
    TfE        = 0.2;
    %% IDC
    IdcNF      = -1;
    IdcPF      = -1;

elseif strcmp(Command,'TransferringBack')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -1;
    %% Collector    
    STOBiasC   = 1.6;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC-0.7;
    StmC       = STOBiasC;
    DoorCClose = -0.05;
    DoorCOpen  = TopC-0.2;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

elseif strcmp(Command,'TransferBack1')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 0.1;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = -1.5;
    TopC       = -2;
    StmC       = STIBiasC;
    DoorCClose = -3;
    DoorCOpen  = -1.2;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

elseif strcmp(Command,'TransferBack2')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = 0.1;
    DoorEOpen  = 0.1;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = -1.5;
    TopC       = -2;
    StmC       = STIBiasC;
    DoorCClose = -3;
    DoorCOpen  = -1.2;
    %% Thin Film
    TfC        = -0.6;
    TfE        = 0.1;
    %% IDC
    IdcNF      = -1.2;
    IdcPF      = -1.2;

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