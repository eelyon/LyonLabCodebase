sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1.5,-0.5,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

sweepGatesforTransport(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,-2,'neg');

setVal(controlDAC,DoorEOutPort,0);
setVal(controlDAC,DoorEOutPort,-1);
setVal(controlDAC,DoorCInPort,-2);
sweep1DMeasSR830({'Door'},-3,-1.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);
setVal(controlDAC,DoorCOutPort,-1.5);

STVoltage = getVal(controlDAC,STIBiasCPort);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STVoltage-0.3,STVoltage-0.2,STVoltage-0.2],numSteps);
setVal(controlDAC,DoorCInPort,-2);
delay(5)
setVal(controlDAC,DoorCInPort,-3);
% sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STVoltage,STVoltage,STVoltage],numSteps);

setVal(controlDAC,DoorCOutPort,-1.5);
delay(1)
setVal(controlDAC,DoorCOutPort,-3);

sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
% sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
setVal(controlDAC,DoorEInPort,0);
delay(3)
setVal(controlDAC,DoorEInPort,-1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
setVal(controlDAC,DoorEOutPort,0);
setVal(controlDAC,DoorEOutPort,-1);

send33220Trigger(AwgTwiddle)