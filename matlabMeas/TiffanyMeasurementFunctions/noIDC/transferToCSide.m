% transfer voltage configuration (negative left side transfer)

% check and load electrons
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);

% change voltages to be negative
sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,0],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-1.5,-2,-1.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopEPort,-1.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.5,-0.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1.5,-0.5,-0.5,-1.5],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-1.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-1,-1,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-1,-1,-2],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-2.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-1.5,-1.5,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2.5,-1.5,-1.5,-2.5],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-1.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-1,-1,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-1,-1,-2],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-1.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.5,-0.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1.5,-0.5,-0.5,-1.5],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);


sweep1DMeasSR830({'Door'},-2.5,-0.7,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEOutPort},0,1);
sweep1DMeasSR830({'Door'},0,-1,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

% clean electrons out of HEMT2 side
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,0,1],numSteps);
sweep1DMeasSR830({'Door'},-1,0.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);


