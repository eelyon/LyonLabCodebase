%% transfer electrons from the collector side by making the other side (+)

%% add in electrons   
% let in electrons
setVal(controlDAC,DoorCOutPort,-1); % close door
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.3,0,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

%% transfer to TF configuration 
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-0.8,0,0,-1],numSteps*5);
setVal(controlDAC,DoorEOutPort,-0.8);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-0.8,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[1,-3,-2,-3],numSteps*5);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);

%% transfer back into twiddle sense area
sigDACRampVoltage(controlDAC,TfEPort,0.3,numSteps*5);
sigDACRampVoltage(controlDAC,BEPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,TfEPort,-0.5,numSteps*5);
sigDACRampVoltage(controlDAC,BEPort,-1.2,numSteps*5);
sigDACRampVoltage(controlDAC,TfEPort,-1,numSteps*5);
sigDACRampVoltage(controlDAC,BEPort,-1.5,numSteps*5);
sigDACRampVoltage(controlDAC,TfEPort,-1.5,numSteps*5);
sigDACRampVoltage(controlDAC,BEPort,-2.5,numSteps*5);
sigDACRampVoltage(controlDAC,TfEPort,-2.5,numSteps*5);
sigDACRampVoltage(controlDAC,BEPort,-3.5,numSteps*5);

setVal(controlDAC,DoorCOutPort,0); % open door
sweep1DMeasSR830({'TFC'},1,-1.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TfCPort},0,1);

sweep1DMeasSR830({'Door'},0,-1,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);


%% optionally, check transfer
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-0.5,2.5,2.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps*5);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);

% clean any electrons off
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
