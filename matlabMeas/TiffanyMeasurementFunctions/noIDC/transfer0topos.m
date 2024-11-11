%% transfer electrons

% transfer configuration 
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[1.3,2,2,2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[1,2,2,2],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[1.5,0.5,-0.5,0],numSteps*5);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorCOutPort,1,numSteps*5);

% set voltage back
sigDACRampVoltage(controlDAC,TopCPort,0.8,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1.5,1.5,1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0.5,1.5,1.5,0],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,0.3,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,1,1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,1,1,-0.5],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,-0.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-0.5,0.5,0.5,-1],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleCPort},1,1);

% clean off from TFC
setVal(controlDAC,BCPort,-1)
sweep1DMeasSR830({'TFC'},1,-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{TfCPort},0,1);
