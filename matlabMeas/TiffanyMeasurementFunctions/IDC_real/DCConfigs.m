function [ errstr ] = DCConfigs( Command )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
DCMap;
if strcmp(Command,'Emitting')
    %% Emitter
    TopE       = -1;
    StmE       = 0;
    DoorE      = -1;
    %% Collector    
    BiasC      = 0;
    TopC       = BiasC-1;
    StmC       = BiasC;
    DoorC      = BiasC-1;
    %% Thin Film
    TfC        = -8;
    TfE        = -8;
    %% IDC
    IdcNG      = -5;
    IdcNF      = -5;
    IdcPG      = -5;
    IdcPF      = -5;
    %% Top Metal
    TopMetal   = -5;
elseif strcmp(Command,'Transfering')
    %% Emitter    
    TopE       = -.8;
    StmE       = 0;
    DoorE      = -1;
    %% Collector    
    BiasC      = 9;
    TopC       = BiasC-.8;
    StmC       = BiasC;
    DoorC      = BiasC-1;
    %% Thin Film
    TfC        = 5;
    TfE        = 4;
    %% IDC
    IdcN       = 0;
    IdcP       = 20;
    %% Top Metal
    TopMetal   = -15;
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
    IdcN       = 0;
    IdcP       = 0;
    %% Top Metal
    TopMetal   = 0;
end


%% Setting

DCTime = 0.1;
errTE = setVal(TopEDevice,TopEPort,TopE);
pause(DCTime)
errSE = setVal(StmEDevice,StmEPort,StmE);
pause(DCTime)
errDE = setVal(DoorEDevice,DoorEPort,DoorE);
pause(DCTime)
errBE = setVal(BiasCDevice,BiasCPort,BiasC);
pause(DCTime)
errTC = setVal(TopCDevice,TopCPort,TopC);
pause(DCTime)
errSC = setVal(StmCDevice,StmCPort,StmC);
pause(DCTime)
errDC = setVal(DoorCDevice,DoorCPort,DoorC);
pause(DCTime)
errING = setVal(IdcNGDevice,IdcNGPort,IdcNG);
pause(DCTime)
errIPG = setVal(IdcPGDevice,IdcPGPort,IdcPG);
pause(DCTime)
errINF = setVal(IdcNFDevice,IdcNFPort,IdcNF);
pause(DCTime)
errIPF = setVal(IdcPFDevice,IdcPFPort,IdcPF);
pause(DCTime)
errFE = setVal(TfEDevice,TfEPort,TfE);
pause(DCTime)
errFC = setVal(TfCDevice,TfCPort,TfC);
pause(DCTime)
errTM = setVal(TopMetalDevice,TopMetalPort,TopMetal);

errstr = [errTE errSE errDE errBE errTC errSC errDC errING errINF errIPG errIPF errFE errFC errTM];


