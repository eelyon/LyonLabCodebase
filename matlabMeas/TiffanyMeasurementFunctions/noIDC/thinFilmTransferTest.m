%% Transfer to thin film line and back
% device tuning procedure, emit to both sommer tanners

% HEMT1 side (overall 0)
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-3,0,-3],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,0.75,0,-3],numSteps);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,BEPort,-2,numSteps);
sigDACRampVoltage(controlDAC,TfEPort,-0.5,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sweep1DMeasSR830({'TWW'},0,-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);


% HEMT2 side (overall 0)
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-3],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0.5,-3,-3,-1],numSteps);

sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,BCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-0.5,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

sigDACRampVoltage(controlDAC,TfCPort,0.7,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0.5,-3,-3,0],numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-0.5,-2,-2.5],numSteps);



% transfer from HEMT2 to HEMT1 side
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-3,0,-3],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,0.5,0,-3],numSteps);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,BEPort,-1,numSteps);
sigDACRampVoltage(controlDAC,TfEPort,-0.5,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);