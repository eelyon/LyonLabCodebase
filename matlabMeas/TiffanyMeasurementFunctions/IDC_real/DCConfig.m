%% Emitter
TopE       = 0.01;

StmE       = 0.02;

DoorE      = 0.03;

%% Collector
TopC       = 0.04;

StmC       = 0.05;

DoorC      = 0.06;

BiasC      = 0.07;

%% Thin Film

TfC        = 0.08;

TfE        = 0.09;

%% IDC
IdcN       = 0.1;

IdcP       = 0.12;

%% Top Metal
TopMetal   = 0.13;


%% Setting

DCTime = 0.5;
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
errIN = setVal(IdcNDevice,IdcNPort,IdcN);
pause(DCTime)
errIP = setVal(IdcPDevice,IdcPPort,IdcP);
pause(DCTime)
errFE = setVal(TfEDevice,TfEPort,TfE);
pause(DCTime)
errFC = setVal(TfCDevice,TfCPort,TfC);
pause(DCTime)
errTM = setVal(TopMetalDevice,TopMetalPort,TopMetal);

[errTE errSE errDE errBE errTC errSC errDC errIN errIP errFE errFC errTM]

