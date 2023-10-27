%% Transfer Measurement Procedure

% IDC sweep to make sure there's enough helium
IDCVoltageSweep;

% emit electrons and measure
DCConfigDAC(DAC,'Emitting',1000);
sigDACRampVoltage(DAC,5,-2,1000)

start = 0;
deltaParam = 0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

start = 0;
deltaParam = 0.02;
stop = -0.35;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% Transfer
DCConfigDAC(DAC,'Transferring1',10000);
pause(10)

DCConfigDAC(DAC,'Transferring2',10000);
pause(10)

DCConfigDAC(DAC,'Transfer',10000);
pause(10)

% Door Sweep

start = sigDACQueryVoltage(DAC,DoorEClosePort);
deltaParam = -0.025;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);

% After transfer sweeps
start = 1.1; %sigDACQueryVoltage(DAC,StmCPort);
deltaParam = -0.025;
stop = start-0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);

start = 0;
deltaParam = 0.025;
stop = -0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% Transfer Back
DCConfigDAC(DAC,'TransferringBack',10000);
pause(10)

DCConfigDAC(DAC,'TransferBack1',10000);
pause(10)

DCConfigDAC(DAC,'TransferBack2',10000);
pause(10)

start = sigDACQueryVoltage(DAC,DoorCClosePort);
deltaParam = 0.05;
stop = -0.6;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{DoorCClosePort},0);

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

sigDACRampVoltage(DAC,STOBiasCPort,-1.5,1000)
pause(1)
sigDACRampVoltage(DAC,StmCPort,-1.5,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasCPort,-1.5,1000)
pause(1)

sigDACRampVoltage(DAC,DoorEClosePort,-1,1000)

start = 0;
deltaParam = 0.02;
stop = -0.35;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement
