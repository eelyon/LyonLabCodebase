%% transfer electrons from the emitter side by making the other side (+)

%% add in electrons   
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.4,-0.3,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);

%% transfer to TF configuration 
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,2.5,2.5,2.5],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[1.5,1,0,0.5],numSteps*5);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

%% transfer back into twiddle sense area
sigDACRampVoltage(controlDAC,TfCPort,0.3,numSteps*5);
sigDACRampVoltage(controlDAC,BCPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,TfCPort,-0.5,numSteps*5);
sigDACRampVoltage(controlDAC,BCPort,-1.2,numSteps*5);
sigDACRampVoltage(controlDAC,TfCPort,-1,numSteps*5);
sigDACRampVoltage(controlDAC,BCPort,-1.5,numSteps*5);

sweep1DMeasSR830({'TFE'},0.5,-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{TfEPort},0,1);

sweep1DMeasSR830({'Door'},0,-1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},0,1);

% check for electrons on the other side
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,2.5,2.5,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps*5);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

