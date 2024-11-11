% change voltages to be negative
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,0],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[2,1,0.7,1.7],numSteps*5);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-0.5,0.5,0.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,-0.2,numSteps*5);

sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,1,1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,1,1,0],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,0.3,numSteps*5);

sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1.5,1.5,1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0.5,1.5,1.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,0.8,numSteps*5);

sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[2,2,2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[1,2,2,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,1.3,numSteps*5);

sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[2.5,2.5,2.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[1.5,2.5,2.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,1.8,numSteps*5);

setVal(controlDAC,DoorCOutPort,2.5);
pause(2)
setVal(controlDAC,DoorCOutPort,1);

sigDACRampVoltage(controlDAC,TopCPort,1.3,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[2,2,2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[1,2,2,1],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,0.8,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1.5,1.5,1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0.5,1.5,1.5,0.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,0.3,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,1,1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,1,1,0],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-0.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-0.5,0.5,0.5,-0.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps*5);






sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sweep1DMeasSR830({'Door'},0,-1,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);