function [ errstr ] = DCConfigs2Tau( Command, numSteps )
%   Summary of this function goes here
%   Detailed explanation goes here

DCMap;
if strcmp(Command,'Emitting')
    %% Emitter    
    TopE       = -2;
    StmE       = 0;
    DoorE      = -2;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 0-9;
    TopC       = BiasC-1;
    StmC       = BiasC;
    DoorC      = BiasC;
    DoorCOpen  = 7;
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
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = 3 ;
    TopC       = BiasC-2;
    StmC       = BiasC;
    DoorC      = -5;
    DoorCOpen  = BiasC;
    
    %% Thin Film
    TfC        = 2;
    TfE        = 1;
    %% IDC
    IdcNG      = -1;
    IdcNF      = 0;
    IdcPG      = -2;
    IdcPF      = 0;
    %% Top Metal
    TopMetal   = -5;
elseif strcmp(Command,'Zero')
    %% Emitter
    TopE       = 0;
    StmE       = 0;
    DoorE      = 0;
    DoorEOpen  = 1;
    %% Collector
    TopC       = 0;
    StmC       = 0;
    DoorC      = 0;
    DoorCOpen  = 1;
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
elseif strcmp(Command,'TransferBack')
    %% Emitter    
    TopE       = -2;
    StmE       = 0;
    DoorE      = -8;
    DoorEOpen  = 0;
    %% Collector    
    BiasC      = -3 ;
    TopC       = BiasC-2;
    StmC       = BiasC;
    DoorC      = -5;
    DoorCOpen  = BiasC;
    %% Thin Film
    TfC        = -2;
    TfE        = -1;
    %% IDC
    IdcNG      = -4;
    IdcNF      = 0;
    IdcPG      = -3;
    IdcPF      = 0;
    %% Top Metal
    TopMetal   = -8;
end

%% Delta Values
 if ~exist('numSteps','var')
     numSteps= 1;
 end
 DCTime = .1;
 
    %% Emitter
    TopEd       = -(getVal(TopEDevice,TopEPort)-TopE)/numSteps;

    StmEd       = -(getVal(StmEDevice,StmEPort)-StmE)/numSteps;

    DoorEd      = -(getVal(DoorEDevice,'LOW')-DoorE)/numSteps;

    DoorEOpend      = -(getVal(DoorEDevice,'HIGH')-DoorEOpen)/numSteps;

    %% Collector    
    BiasCd      = -(getVal(BiasCDevice,BiasCPort)-BiasC)/numSteps;

    TopCd       = -(getVal(TopCDevice,TopCPort)-TopC)/numSteps;

    StmCd       = -(getVal(StmCDevice,StmCPort)-StmC)/numSteps;

    DoorCd      = -(getVal(DoorCDevice,'LOW')-DoorC)/numSteps;

    DoorCOpend  = -(getVal(DoorCDevice,'HIGH')-DoorCOpen)/numSteps;

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
    DoorEo      = getVal(DoorEDevice,'LOW');
    DoorEOpeno  = getVal(DoorEDevice,'HIGH');
    %% Collector    
    BiasCo      = getVal(BiasCDevice,BiasCPort);
    TopCo       = getVal(TopCDevice,TopCPort);
    StmCo       = getVal(StmCDevice,StmCPort);
    DoorCo      = getVal(DoorCDevice,'LOW');
    DoorCOpeno  = getVal(DoorCDevice,'HIGH');
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
    DoorEOpeno  = DoorEOpeno+DoorEOpend;
    %% Collector    
    BiasCo      = BiasCo+BiasCd;
    TopCo       = TopCo+TopCd;
    StmCo       = StmCo+StmCd;
    DoorCo      = DoorCo+DoorCd;
    DoorCOpeno  = DoorCOpeno+DoorCOpend;
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
    
    if DoorEd < 0 % closed door value
        errDE = setVal(DoorEDevice,'LOW',DoorEo);
        pause(DCTime)
        errDOE = setVal(DoorEDevice,'HIGH',DoorEOpeno);
        pause(DCTime)
    else
        errDOE = setVal(DoorEDevice,'HIGH',DoorEOpeno);
        pause(DCTime)
        errDE = setVal(DoorEDevice,'LOW',DoorEo);
        pause(DCTime)
    end
    errDOE=0;
    errDE=0;
    
    errBE = setVal(BiasCDevice,BiasCPort,BiasCo);
    %pause(DCTime)
    errTC = setVal(TopCDevice,TopCPort,TopCo);
   % pause(DCTime)
    errSC = setVal(StmCDevice,StmCPort,StmCo);
    pause(DCTime)
    if DoorCd < 0 
        errDC = setVal(DoorCDevice,'LOW',DoorCo);
        %pause(DCTime)
        errDOC = setVal(DoorCDevice,'HIGH',DoorCOpeno);
       % pause(DCTime)
    else
        errDOC = setVal(DoorCDevice,'HIGH',DoorCOpeno);
       % pause(DCTime)
        errDC = setVal(DoorCDevice,'LOW',DoorCo);
       % pause(DCTime)
    end
    errDOC=0;
    errDC=0;
    
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
    %pause(DCTime)
    errTM = setVal(TopMetalDevice,TopMetalPort,TopMetalo);
    errstr = [errTE errSE errDE errDOE errBE errTC errSC errDC errDOC errING errINF errIPG errIPF errFE errFC errTM];
end

