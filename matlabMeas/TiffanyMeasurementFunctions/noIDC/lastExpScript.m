sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-2.5,-0.5,-4,-2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

sweepGatesforTransport(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,-3,'neg');

setVal(controlDAC,DoorEOutPort,0);
setVal(controlDAC,DoorEOutPort,-1);
setVal(controlDAC,DoorCInPort,-2);
sweep1DMeasSR830({'Door'},-3,-1.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);
setVal(controlDAC,DoorCOutPort,-1.5);

% load electrons in on HEMT2 side
STVoltage = getVal(controlDAC,STIBiasCPort);
setVal(controlDAC,DoorCInPort,-3);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STVoltage-0.4,STVoltage-0.2,STVoltage-0.2],numSteps);
delay(5)
setVal(controlDAC,DoorCInPort,-4);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STVoltage,STVoltage,STVoltage],numSteps);

setVal(controlDAC,DoorCOutPort,-2.5);
delay(1)
setVal(controlDAC,DoorCOutPort,-4);

%% clean electrons HEMT1 into reservoir
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
% sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
setVal(controlDAC,DoorEInPort,0);
delay(3)
setVal(controlDAC,DoorEInPort,-1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
setVal(controlDAC,DoorEOutPort,0);
setVal(controlDAC,DoorEOutPort,-1);

%% clean electrons into reservoir from thin film
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
setVal(controlDAC,DoorEInPort,0);
setVal(controlDAC,DoorEOutPort,0);

setVal(controlDAC,TfEPort,-2);

setVal(controlDAC,DoorEOutPort,-1);
setVal(controlDAC,DoorEInPort,-1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
setVal(controlDAC,TfEPort,-0.5);


send33220Trigger(AwgTwiddle)