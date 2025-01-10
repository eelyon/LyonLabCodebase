sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1.5,-1,-1.5,-2],numSteps*5);

sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1.5],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-1.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.5,0,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1.5,-0.5,-0.5,-1.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-1.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-1,-1,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-1,-1,-2],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-2.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-1.5,-1.5,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2.5,-1.5,-1.5,-2.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-2.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-2,-2,-2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-2,-2,-2],numSteps*5);

sigDACRampVoltage(controlDAC,TopCPort,-3.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-2.5,-2.5,-2.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3.5,-2.5,-2.5,-3.5],numSteps*5);

setVal(controlDAC,DoorEOutPort,0);
sweep1DMeasSR830({'Door'},-3.5,-2.5,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorCOutPort},1,1);
sweep1DMeasSR830({'Door'},0,-1,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},0,1);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-2,-2,-2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-2,-2,-2],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,-2.7,numSteps*5);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-1.5,-1.5,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2.5,-1.5,-1.5,-2.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,-2.2,numSteps*5);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-1,-1,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-1,-1,-2],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,-1.7,numSteps*5);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.5,-0.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1.5,-0.5,-0.5,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,-1.2,numSteps*5);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopCPort,-0.7,numSteps*5);

sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);