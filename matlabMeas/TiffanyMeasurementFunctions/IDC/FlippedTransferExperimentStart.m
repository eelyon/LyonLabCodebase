start = 0; % sigDACQueryVoltage(DAC,StmCPort);
deltaParam = -0.02;
stop = start-0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasC},DAC,{StmCPort},1);

DCConfigDAC(DAC,'FlipTransfer1',8000);
pause(9)

sigDACRampVoltage(DAC,1,0.6,1000);
sigDACRampVoltage(DAC,3,0.3,1000);



DCConfigDAC(DAC,'FlipTransfer',8000);
pause(9)

start = sigDACQueryVoltage(DAC,DoorCClosePort);
deltaParam = 0.05;
stop = 1.5;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{DoorCClosePort},0);

start = 2.6;
deltaParam = -0.02;
stop = start-0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasE},DAC,{StmEPort},1);

DCConfigDAC(DAC,'FlipTransferBack1',10000);
pause(10)

DCConfigDAC(DAC,'FlipTransferBack2',10000);
pause(10)

DCConfigDAC(DAC,'FlipTransferBack',10000);
pause(10)

sigDACRampVoltage(DAC,DoorEClosePort,-1.3,1000)

sigDACRampVoltage(DAC,DoorEClosePort,-1.5,1000)

sigDACRampVoltage(DAC,STOBiasEPort,-1.8,1000)
pause(1)
sigDACRampVoltage(DAC,StmEPort,-1.8,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasEPort,-1.8,1000)
pause(1)
sigDACRampVoltage(DAC,STOBiasEPort,-1.5,1000)
pause(1)
sigDACRampVoltage(DAC,StmEPort,-1.5,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasEPort,-1.5,1000)
pause(1)

