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
    DoorEOpen  = 0;
    %% Collector    
    STOBiasC   = -4;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC;
    StmC       = STOBiasC;
    DoorCClose = STOBiasC;
    DoorCOpen  = STOBiasC+1;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[-1,-1,-1],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-4,-4,-4],1000);

elseif strcmp(Command,'Transferring1')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -0.3;
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

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-4,-4,-4],1000);

elseif strcmp(Command,'Transferring2')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -0.4;
    %% Collector   
    STOBiasC   = 1.1;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC-0.7;
    StmC       = STOBiasC;
    DoorCClose = 0.8;
    DoorCOpen  = 0.7;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[STOBiasC,STOBiasC,STOBiasC],1000);


elseif strcmp(Command,'Transfer')
    %% Emitter    
    TopE       = -0.7;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = 1.5;
    %% Collector
    STMC = 3;
    STOBiasC   = STMC;
    STIBiasC   = STMC;
    TopC       = STOBiasC-0.25;
    StmC       = STMC;
    DoorCClose = 2;
    DoorCOpen  = 0.8; %TopC-0.2;
    %% Thin Film
    TfC        = 2;  %0.6
    TfE        = 1.5;  %0.3
    %% IDC
    IdcNF      = -0.3;
    IdcPF      = -0.3;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000); 
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[STMC,STMC,STMC],1000);

elseif strcmp(Command,'Transfer_smaller')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -0.1;
    %% Collector
    STMC = 0.5;  %1.1
    STOBiasC   = STMC;
    STIBiasC   = STMC;
    TopC       = STOBiasC-0.5;
    StmC       = STMC;
    DoorCClose = -0.3; %-1;
    DoorCOpen  = 0.5; %TopC-0.2;
    %% Thin Film
    TfC        = 0.4;  %0.6
    TfE        = 0.1;  %0.3
    %% IDC
    IdcNF      = 0;
    IdcPF      = 0;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[STMC,STMC,STMC],1000);


elseif strcmp(Command,'TransferringBack')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -0.1;
    %% Collector    
    STOBiasC   = 1.1;
    STIBiasC   = STOBiasC;
    TopC       = STOBiasC-0.5;
    StmC       = STOBiasC;
    DoorCClose = -3;
    DoorCOpen  = 0.7;
    %% Thin Film
    TfC        = -2;
    TfE        = -2;
    %% IDC
    IdcNF      = -2;
    IdcPF      = -2;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[STOBiasC,STOBiasC,STOBiasC],1000);

elseif strcmp(Command,'TransferBack1')
    %% Emitter    
    TopE       = TopVoltage;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -1;
    DoorEOpen  = -0.1;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = STOBiasC;
    TopC       = -2;
    StmC       = STOBiasC;
    DoorCClose = -2.3;
    DoorCOpen  = -0.8;
    %% Thin Film
    TfC        = -2;
    TfE        = -2;
    %% IDC
    IdcNF      = -2;
    IdcPF      = -2;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[STOBiasC,STOBiasC,STOBiasC],1000);

elseif strcmp(Command,'TransferBack2')
    %% Emitter    
    TopE       = -0.7;
    StmE       = 0;
    STOBiasE   = 0;
    STIBiasE   = 0;
    DoorEClose = -0.1;
    DoorEOpen  = 0;
    %% Collector    
    STOBiasC   = -1.5;
    STIBiasC   = STOBiasC;
    TopC       = -2;
    StmC       = STOBiasC;
    DoorCClose = -2.3;
    DoorCOpen  = -1;
    %% Thin Film
    TfC        = -0.8;
    TfE        = -0.4;
    %% IDC
    IdcNF      = -1.1;
    IdcPF      = -1.1;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[STOBiasC,STOBiasC,STOBiasC],1000);

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
    
    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[0,0,0],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[0,0,0],1000);

 elseif strcmp(Command,'Clean')
    %% Emitter    
    TopE       =  -5;
    StmE       = -5;
    STOBiasE   = -5;
    STIBiasE   = -5;
    DoorEClose = -5;
    DoorEOpen  = -5;
    %% Collector    
    STOBiasC   = -5;
    STIBiasC   = -5;
    TopC       =  2;
    StmC       = -5;
    DoorCClose = -5;
    DoorCOpen  = -5;
    %% Thin Film
    TfC        = -5;
    TfE        = -5;
    %% IDC
    IdcNF      = -5;
    IdcPF      = -5;
    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[-5,-5,-5],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-5,-5,-5],1000);

elseif strcmp(Command,'FlipEmit')
    %% Emitter    
    TopE       = -4;
    StmE       = -4;
    STOBiasE   = -4;
    STIBiasE   = -4;
    DoorEClose = -4;
    DoorEOpen  = -4;
    %% Collector
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = -0.7;
    StmC       = 0;
    DoorCClose = -1;
    DoorCOpen  = -1; %TopC-0.2;
    %% Thin Film
    TfC        = -3;
    TfE        = -3;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[StmE,StmE,StmE],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[0,0,0],1000);

elseif strcmp(Command,'FlipTransfer1')
    %% Emitter    
    TopE       = 3.3;
    StmE       = 3.6;
    STOBiasE   = 3.6;
    STIBiasE   = 3.6;
    DoorEClose = -1;
    DoorEOpen  = 3.5;
    %% Collector
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = -0.7;
    StmC       = 0;
    DoorCClose = -2; %2;
    DoorCOpen  =  2; %TopC-0.2;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[StmE,StmE,StmE],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[0.5,0.5,0.5],1000);

elseif strcmp(Command,'FlipTransfer')
    %% Emitter    
    TopE       = 3.3;
    StmE       = 3.6;
    STOBiasE   = 3.6;
    STIBiasE   = 3.6;
    DoorEClose = -3;
    DoorEOpen  = 3.5;
    %% Collector
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = -0.7;
    StmC       = 0;
    DoorCClose = -1; %2;
    DoorCOpen  = 2;  %TopC-0.2;
    %% Thin Film
    TfC        = 2;
    TfE        = 2.5;
    %% IDC
    IdcNF      = -1.2;
    IdcPF      = -1.2;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[StmE,StmE,StmE],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[0.5,0.5,0.5],1000);

elseif strcmp(Command,'FlipTransferBack1')
    %% Emitter    
    TopE       = 3.3;
    StmE       = 3.6;
    STOBiasE   = 3.6;
    STIBiasE   = 3.6;
    DoorEClose = -1;
    DoorEOpen  = 3.5;
    %% Collector
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = -0.7;
    StmC       = 0;
    DoorCClose = -1; %2;
    DoorCOpen  = 2; %TopC-0.2;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[StmE,StmE,StmE],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[0.5,0.5,0.5],1000);

elseif strcmp(Command,'FlipTransferBack2')
    %% Emitter    
    TopE       = -3.6;
    StmE       = -3.3;
    STOBiasE   = -3.3;
    STIBiasE   = -3.3;
    DoorEClose = -4;
    DoorEOpen  = -3.3;
    %% Collector
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = -0.7;
    StmC       = 0;
    DoorCClose = 0; %2;
    DoorCOpen  = 2; %TopC-0.2;
    %% Thin Film
    TfC        = -4;
    TfE        = -4;
    %% IDC
    IdcNF      = -4;
    IdcPF      = -4;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[-2.8,-2.8,-2.8],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[0.5,0.5,0.5],1000);

elseif strcmp(Command,'FlipTransferBack')
    %% Emitter    
    TopE       = -3.6;
    StmE       = -3.3;
    STOBiasE   = -3.3;
    STIBiasE   = -3.3;
    DoorEClose = -4; % -3.3
    DoorEOpen  = -3.3;
    %% Collector
    STOBiasC   = 0;
    STIBiasC   = 0;
    TopC       = -0.7;
    StmC       = 0;
    DoorCClose = -0.6; %2;
    DoorCOpen  = -5;
    %% Thin Film
    TfC        = -2;
    TfE        = -2.5;
    %% IDC
    IdcNF      = -3;
    IdcPF      = -3;

    sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[-2.8,-2.8,-2.8],1000);
    pause(2)
    sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-0.3,-0.3,-0.3],1000);

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