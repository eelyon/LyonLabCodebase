function [ errstr ] = DCConfigs2( Command )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
DCMap;
if strcmp(Command,'Emitting')
    %% Emitter    
    TopE       = -1;
    StmE       = 0;
    DoorE      = -2;
    %% Collector    
    BiasC      = -9;
    TopC       = BiasC-1;
    StmC       = BiasC;
    DoorC      = BiasC-1;
    %% Thin Film
    TfC        = -5;
    TfE        = -5;
    %% IDC
    IdcNG      = -5;
    IdcNF      = 0;
    IdcPG      = -5;
    IdcPF      = 0;
    %% Top Metal
    TopMetal   = -5;
elseif strcmp(Command,'Transfer')
    %% Emitter    
    TopE       = -2;
    StmE       = 0;
    DoorE      = -2;
    %% Collector    
    BiasC      = 3 ;
    TopC       = BiasC-2;
    StmC       = BiasC;
    DoorC      = -5;
    %% Thin Film
    TfC        = 1.1;
    TfE        = 1.9;
    %% IDC
    IdcNG      = -1;
    IdcNF      = 0;
    IdcPG      = 0;
    IdcPF      = 0;
    %% Top Metal
    TopMetal   = -5;
elseif strcmp(Command,'TransferBack')
    %% Emitter    
    TopE       = -2;
    StmE       = 0;
    DoorE      = -2;
    %% Collector    
    BiasC      = -9;
    TopC       = BiasC-1;
    StmC       = BiasC;
    DoorC      = BiasC-1;
    %% Thin Film
    TfC        = -6;
    TfE        = -2;
    %% IDC
    IdcNG      = -7;
    IdcNF      = 0;
    IdcPG      = -7;
    IdcPF      = 0;
    %% Top Metal
    TopMetal   = -5;
elseif strcmp(Command,'Zero')
    %% Emitter
    TopE       = 0;
    StmE       = 0;
    DoorE      = 0;
    %% Collector
    TopC       = 0;
    StmC       = 0;
    DoorC      = 0;
    BiasC      = 0;
    %% Thin Film
    TfC        = 0;
    TfE        = 0;
    %% IDC
    IdcNG      = 0;
    IdcNF      = 0;
    IdcPG      = 0;
    IdcPF      = 0;
    %% Top Metal
    TopMetal   = 0;    
end

%% Delta Values
 numSteps  = 1;
 DCTime = .1;
 
    %% Emitter
    TopEd       = -(getVal(TopEDevice,TopEPort)-TopE)/numSteps;
        pause(DCTime)
    StmEd       = -(getVal(StmEDevice,StmEPort)-StmE)/numSteps;
        pause(DCTime)
    DoorEd      = -(getVal(DoorEDevice,DoorEPort)-DoorE)/numSteps;
        pause(DCTime)
    %% Collector    
    BiasCd      = -(getVal(BiasCDevice,BiasCPort)-BiasC)/numSteps;
        pause(DCTime)
    TopCd       = -(getVal(TopCDevice,TopCPort)-TopC)/numSteps;
        pause(DCTime)
    StmCd       = -(getVal(StmCDevice,StmCPort)-StmC)/numSteps;
        pause(DCTime)
    DoorCd      = -(getVal(DoorCDevice,DoorCPort)-DoorC)/numSteps;
        pause(DCTime)
    %% Thin Film
    TfCd        = -(getVal(TfCDevice,TfCPort)-TfC)/numSteps;
        pause(DCTime)
    TfEd        = -(getVal(TfEDevice,TfEPort)-TfE)/numSteps;
        pause(DCTime)
    %% IDC
    IdcNGd       = -(getVal(IdcNGDevice,IdcNGPort)-IdcNG)/numSteps;
        pause(DCTime)
    IdcNFd       = -(getVal(IdcNFDevice,IdcNFPort)-IdcNF)/numSteps;
        pause(DCTime)
    IdcPGd       = -(getVal(IdcPGDevice,IdcPGPort)-IdcPG)/numSteps;
        pause(DCTime)
    IdcPFd       = -(getVal(IdcPFDevice,IdcPFPort)-IdcPF)/numSteps;
        pause(DCTime)
    %% Top Metal
    TopMetald   = -(getVal(TopMetalDevice,TopMetalPort)-TopMetal)/numSteps;

    %% Emitter
    TopEo       = getVal(TopEDevice,TopEPort);
    StmEo       = getVal(StmEDevice,StmEPort);
    DoorEo      = getVal(DoorEDevice,DoorEPort);
    %% Collector    
    BiasCo      = getVal(BiasCDevice,BiasCPort);
    TopCo       = getVal(TopCDevice,TopCPort);
    StmCo       = getVal(StmCDevice,StmCPort);
    DoorCo      = getVal(DoorCDevice,DoorCPort);
    %% Thin Film
    TfCo        = getVal(TfCDevice,TfCPort);
    TfEo        = getVal(TfEDevice,TfEPort);
    %% IDC
    IdcNGo       = getVal(IdcNGDevice,IdcNGPort);
    IdcNFo       = getVal(IdcNFDevice,IdcNFPort);
    IdcPGo       = getVal(IdcPGDevice,IdcPGPort);
    IdcPFo       = getVal(IdcPFDevice,IdcPFPort);
    %% Top Metal
    TopMetalo   = getVal(TopMetalDevice,TopMetalPort);


    
    
    
    
for i = 1:numSteps 
    TopEo       = TopEo+TopEd;
    StmEo       = StmEo+StmEd;
    DoorEo      = DoorEo+DoorEd;
    %% Collector    
    BiasCo      = BiasCo+BiasCd;
    TopCo       = TopCo+TopCd;
    StmCo       = StmCo+StmCd;
    DoorCo      = DoorCo+DoorCd;
    %% Thin Film
    TfCo        = TfCo+TfCd;
    TfEo        = TfEo+TfEd;
    %% IDC
    IdcNGo       = IdcNGo+IdcNGd;
    IdcNFo       = IdcNFo+IdcNFd;
    IdcPGo       = IdcPGo+IdcPGd;
    IdcPFo       = IdcPFo+IdcPFd;
    %% Top Metal
    TopMetalo   = TopMetalo+TopMetald;
    

    errTE = setVal(TopEDevice,TopEPort,TopEo);
    pause(DCTime)
    errSE = setVal(StmEDevice,StmEPort,StmEo);
    pause(DCTime)
    errDE = setVal(DoorEDevice,DoorEPort,DoorEo);
    pause(DCTime)
    errBE = setVal(BiasCDevice,BiasCPort,BiasCo);
    pause(DCTime)
    errTC = setVal(TopCDevice,TopCPort,TopCo);
    pause(DCTime)
    errSC = setVal(StmCDevice,StmCPort,StmCo);
    pause(DCTime)
    errDC = setVal(DoorCDevice,DoorCPort,DoorCo);
    pause(DCTime)
    errING = setVal(IdcNGDevice,IdcNGPort,IdcNGo);
    pause(DCTime)
    errINF = setVal(IdcNFDevice,IdcNFPort,IdcNFo);
    pause(DCTime)
    errIPG = setVal(IdcPGDevice,IdcPGPort,IdcPGo);
    pause(DCTime)
    errIPF = setVal(IdcPFDevice,IdcPFPort,IdcPFo);
    pause(DCTime)
    errFE = setVal(TfEDevice,TfEPort,TfEo);
    pause(DCTime)
    errFC = setVal(TfCDevice,TfCPort,TfCo);
    pause(DCTime)
    errTM = setVal(TopMetalDevice,TopMetalPort,TopMetalo);
    errstr = [errTE errSE errDE errBE errTC errSC errDC errING errINF errIPG errIPF errFE errFC errTM];
end

