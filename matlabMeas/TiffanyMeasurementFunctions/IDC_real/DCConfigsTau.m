
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
DCMap;

    %% Emitter    
    TopE       = VTop;
    StmE       = 0;
    DoorEHigh  = VclosedE;
    DoorELow   = VopenE; 
    %% Collector    
    TopC       = BiasC+VTop;
    StmC       = BiasC;
    DoorCHigh  = BiasC+VclosedC;
    DoorCLow   = BiasC+VopenC;
    %% Thin Film
    TfC        = BiasC;
    TfE        = 0;
    %% IDC
    IdcNG      = VIDCNTau/2;
    IdcNF      = VIDCNTau/2;
    IdcPG      = VIDCPTau/2;
    IdcPF      = VIDCPTau/2;
    %% Top Metal
    TopMetal   = VTopMetal;
 

%% Delta Values
 numSteps  = 30;
 DCTime = 0.1;
 
    %% Emitter
    TopEd       = -(getVal(TopEDevice,TopEPort)-TopE)/numSteps;
    StmEd       = -(getVal(StmEDevice,StmEPort)-StmE)/numSteps;
    DoorEdLow   = -(getVal(DoorEDevice,1)-DoorELow)/numSteps;
    DoorEdHigh  = -(getVal(DoorEDevice,2)-DoorEHigh)/numSteps;
    %% Collector    
    BiasCd      = -(getVal(BiasCDevice,BiasCPort)-BiasC)/numSteps;
    TopCd       = -(getVal(TopCDevice,TopCPort)-TopC)/numSteps;
    StmCd       = -(getVal(StmCDevice,StmCPort)-StmC)/numSteps;
    DoorCdLow   = -(getVal(DoorCDevice,1)-DoorCLow)/numSteps;
    DoorCdHigh  = -(getVal(DoorCDevice,2)-DoorCHigh)/numSteps;
    %% Thin Film
    TfCd        = -(getVal(TfCDevice,TfCPort)-TfC)/numSteps;
    TfEd        = -(getVal(TfEDevice,TfEPort)-TfE)/numSteps;
    %% IDC
    IdcNGd       = -(getVal(IdcNGDevice,IdcNGPort)-IdcNG)/numSteps;
    IdcNFd       = -(getVal(IdcNFDevice,IdcNFPort)-IdcNF)/numSteps;
    IdcPGd       = -(getVal(IdcPGDevice,IdcPGPort)-IdcPG)/numSteps;
    IdcPFd       = -(getVal(IdcPFDevice,IdcPFPort)-IdcPF)/numSteps;
    %% Top Metal
    TopMetald   = -(getVal(TopMetalDevice,TopMetalPort)-TopMetal)/numSteps;

    %% Emitter
    TopEo       = getVal(TopEDevice,TopEPort);
    StmEo       = getVal(StmEDevice,StmEPort);
    DoorEoLow   = getVal(DoorEDevice,1);
    DoorEoHigh  = getVal(DoorEDevice,2);
    %% Collector    
    BiasCo      = getVal(BiasCDevice,BiasCPort);
    TopCo       = getVal(TopCDevice,TopCPort);
    StmCo       = getVal(StmCDevice,StmCPort);
    DoorCoLow   = getVal(DoorCDevice,1);
    DoorCoHigh  = getVal(DoorCDevice,2);
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
    if DoorEd > 0
        errDE = setVal(DoorEDevice,2,DoorEoHigh);
        pause(DCTime)
        errDE = setVal(DoorEDevice,1,DoorEoLow);
        pause(DCTime)
    else
        errDE = setVal(DoorEDevice,1,DoorEoLow);
        pause(DCTime)
        errDE = setVal(DoorEDevice,2,DoorEoHigh);
        pause(DCTime)
    end
    errBE = setVal(BiasCDevice,BiasCPort,BiasCo);
    pause(DCTime)
    errTC = setVal(TopCDevice,TopCPort,TopCo);
    pause(DCTime)
    errSC = setVal(StmCDevice,StmCPort,StmCo);
    pause(DCTime)
    if DoorCd > 0
        errDC = setVal(DoorCDevice,2,DoorCoHigh);
        pause(DCTime)
        errDC = setVal(DoorCDevice,1,DoorCoLow);
        pause(DCTime)
    else
        errDC = setVal(DoorCDevice,1,DoorCoLow);
        pause(DCTime)
        errDC = setVal(DoorCDevice,2,DoorCoHigh);
        pause(DCTime)
    end
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

