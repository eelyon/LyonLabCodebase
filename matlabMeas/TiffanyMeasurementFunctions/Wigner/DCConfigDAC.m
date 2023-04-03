function [ ] = DCConfigDAC( DAC, Command, numSteps )
%   ramps all the device ports to a voltage given a command

turnOnHelium = 0;
TopVoltage = -0.7;
DCMap;

if strcmp(Command,'Emitting')

    %% Emitter    
    TopE       = TopVoltage;
    BiasE      = 0;
    DoorEClose = 0;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 0;
    TopC       = -0.7;
    DoorCClose = 0;
    DoorCOpen  = 0;
    %% Thin Film
    TfC        = 0;
    TfE        = 0;
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;

elseif strcmp(Command,'Transfer')
    %% Emitter    
    TopE       = TopVoltage;
    BiasE      = 0;
    DoorEClose = 0;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 0;
    TopC       = 0.1;
    DoorCClose = 0;
    DoorCOpen  = 0;
    %% Thin Film
    TfC        = 0;
    TfE        = 0;
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;

elseif strcmp(Command,'TransferBack')
    %% Emitter    
    TopE       = TopVoltage;
    BiasE      = 0;
    DoorEClose = 0;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 0;
    TopC       = -0.7;
    DoorCClose = 0;
    DoorCOpen  = 0;
    %% Thin Film
    TfC        = 0;
    TfE        = 0;
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;

 elseif strcmp(Command,'Zero')
    %% Emitter    
    TopE       = 0;
    BiasE      = 0;
    DoorEClose = 0;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 0;
    TopC       = 0;
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
    TopE       = TopVoltage;
    BiasE      = 0;
    DoorEClose = 0;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 0;
    TopC       = -0.7;
    DoorCClose = 0;
    DoorCOpen  = 0;
    %% Thin Film
    TfC        = 0;
    TfE        = 0;
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;
    
end

% RAMP
chanList = [TopEPort BiasEPort DoorEClosePort DoorEOpenPort BiasCPort TopCPort...
    DoorCClosePort DoorCOpenPort TfCPort TfEPort IdcNFPort IdcPFPort];
voltList = [TopE BiasE DoorEClose DoorEOpen BiasC TopC DoorCClose DoorCOpen TfC TfE... 
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