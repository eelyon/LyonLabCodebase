%% Transfer Measurement Procedure

% IDC sweep to make sure there's enough helium
IDCVoltageSweep;

% emit electrons and measure
DCConfigDAC(DAC,'Emitting',1000);
sigDACRampVoltage(DAC,5,-1.3,1000)

start = 0;
deltaParam = 0.05;
stop = -0.6;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

start = 0;
deltaParam = 0.02;
stop = -0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% Transfer
DCConfigDAC(DAC,'Transferring1',8000);
pause(9)

DCConfigDAC(DAC,'Transferring2',8000);
pause(9)

DCConfigDAC(DAC,'Transfer',8000);
pause(9)

% Door Sweep
sigDACRampVoltage(DAC,DoorCClosePort,1,1000);

start = sigDACQueryVoltage(DAC,DoorEClosePort);
deltaParam = -0.025;
<<<<<<< Updated upstream
stop = -0.1;
=======
stop = -0.2;
>>>>>>> Stashed changes
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);

sigDACRampVoltage(DAC,DoorCClosePort,-1,1000);
sigDACRampVoltage(DAC,DoorEClosePort,-1,1000);

% After transfer sweeps
start = sigDACQueryVoltage(DAC,StmCPort);
deltaParam = -0.02;
<<<<<<< Updated upstream
stop = start-0.15;
=======
stop = start-0.3;
>>>>>>> Stashed changes
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{StmCPort},1);

start = 0;
deltaParam = 0.02;
stop = -0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% Transfer Back
DCConfigDAC(DAC,'TransferringBack',8000);
pause(9)

DCConfigDAC(DAC,'TransferBack1',8000);
pause(9)

DCConfigDAC(DAC,'TransferBack2',8000);
pause(9)

start = sigDACQueryVoltage(DAC,DoorCClosePort);
deltaParam = 0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{DoorCClosePort},0);

sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-0.7,-0.7,-0.7],1000);
pause(2)
sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-0.5,-0.5,-0.5],1000);
pause(2)

sigDACRampVoltage(DAC,STOBiasCPort,-1.7,1000)
pause(7)
sigDACRampVoltage(DAC,StmCPort,-1.7,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasCPort,-1.7,1000)
pause(1)

sigDACRampVoltage(DAC,STOBiasCPort,-1.8,1000)
pause(5)
sigDACRampVoltage(DAC,StmCPort,-1.8,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasCPort,-1.8,1000)
pause(3)

sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort],[-0.3,-0.3,-0.3],1000);
pause(2)

sigDACRampVoltage(DAC,STOBiasCPort,-1.5,1000)
pause(1)
sigDACRampVoltage(DAC,StmCPort,-1.5,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasCPort,-1.5,1000)
pause(1)

sigDACRampVoltage(DAC,DoorEClosePort,-1,1000)

start = 0;
deltaParam = 0.02;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement




start = sigDACQueryVoltage(DAC,DoorEInPort);
deltaParam = 0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{DoorEInPort},1);
