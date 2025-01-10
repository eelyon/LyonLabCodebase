% transfer voltage configuration (positive left side transfer)

% check and load electrons
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);


sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0.5,1,0.5,0],numSteps*5);


% change voltages to be positive
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-0.5,0.5,0.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,TopEPort,-0.2,numSteps*5);


sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[1,1,1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,1,1,0],numSteps*5);
sigDACRampVoltage(controlDAC,TopEPort,0.3,numSteps*5);


% sigDACRampVoltage(controlDAC,TopEPort,0.7,numSteps*5);
% sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[1.5,1.5,1.5],numSteps*5);
% sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0.5,1.5,1.5,0.5],numSteps);

setVal(controlDAC,DoorEOutPort,1); % open door
setVal(controlDAC,DoorEOutPort,0); % close door

sigDACRampVoltage(controlDAC,TopEPort,-0.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-0.5,0.5,0.5,-0.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopEPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,1.3,1.3,1.3],numSteps*5);


sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,1.5,1.5,1.5],numSteps*5);
setVal(controlDAC,DoorEOutPort,1.3); % open door
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);
setVal(controlDAC,DoorEOutPort,-1); % open door
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps*5);


sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);


sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);

% clean electrons out of HEMT2 side
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,0,1],numSteps);
sweep1DMeasSR830({'Door'},-1,0.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);



sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,1.5,1.5,1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,1.5,1.5,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps*5);

