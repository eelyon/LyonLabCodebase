%% Starting up Experiment

DCMap;
numSteps = 5000;
setVal(supplyDAC,BackMetalPort,-1);
setVal(controlDAC,BlockPort,-2);


%% Compensation voltages
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-2,-2,-2,-2],numSteps);

% compensateParasitics(SR830Twiddle,Ag2Nat,Ag2Nat,-180,180,10,0.2,0.3,0.010,0)    % HEMT1
compensateParasitics(SR830TwiddleC,AwgComp,AwgTwiddle,-180,180,10,0.2,0.3,0.010,0)   % HEMT2
compensateParasitics(SR830Twiddle,Awg2Ch,Awg2Ch,-180,0,10,0.3,0.4,0.010,0)   % HEMT1

%% EMISSION VOLTAGES
% emission to HEMT2 side
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-2,0,-2],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-2,0,-2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

% emission to HEMT1 side
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

% emission to both sides
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-2,-0.4,-2],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-2,-0.4,-2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);


%% Sweeps

% check sommer tanner for electrons
sweep1DMeasSR830({'ST'},0,-0.5,-0.05,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);
sweep1DMeasSR830({'ST'},0,-0.5,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmCPort},1);

sweep1DMeasSR830({'ST'},-2,-2-0.65,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmCPort},1);

% sweep top metal 
sweep1DMeasSR830({'TE'},-0.7,-1.1,-0.05,0.1,10,{SR830Twiddle},controlDAC,{TopEPort},1);
sweep1DMeasSR830({'TC'},-0.7,-1.2,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{TopCPort},1);
sweep1DMeasSR830({'TC'},-2.7,-2.7-0.3,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{TopCPort},1);

% sweep twiddle sense or door
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'Door'},-3,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sweep1DMeasSR830({'Door'},-2.5,-1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

sweep1DMeasSR830({'Door'},-2.5,-1,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);
sweep1DMeasSR830({'Door'},-1,0.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);


%% Thin Film Transfer
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-0.8,-0.3,-0.8,-1.3],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0.5,-0.5,-1.2,0],numSteps);


sigDACRampVoltage(controlDAC,[DoorCInPort,DoorCOutPort],[-1.5,-1.5],numSteps);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort],[-0.5,-0.5],numSteps);
sigDACRampVoltage(controlDAC,SenseCPort,-0.5,numSteps*5);
sigDACRampVoltage(controlDAC,SenseCPort,0,numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,-3,-3,-0.5],numSteps);
setVal(controlDAC,DoorCOutPort,-0.5);
delay(3)
setVal(controlDAC,DoorCOutPort,-1.5);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort],[0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,DoorCOutPort],[-1,-1],numSteps);

sweep1DMeasSR830({'TWW'},0,-0.8,0.1,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

setVal(controlDAC,DoorCOutPort,0);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,-3,-3,-2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1.7,-3,-3,-2],numSteps);
delay(3)
setVal(controlDAC,DoorCOutPort,-1);
sweep1DMeasSR830({'TWW'},0,-0.8,0.1,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

setVal(controlDAC,[DoorCInPort,DoorCOutPort],[-1.5,-1.5],numSteps);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort],[-0.5,-0.5],numSteps);


%% change voltage of left side

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,-3,-3,-1.3],numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-3,numSteps*5);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,1],numSteps*5);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort,DoorCOutPort],[-1,-1,1],numSteps*5);
setVal(controlDAC,DoorCOutPort,-1);
delay(3)
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,1],numSteps*5);
sigDACRampVoltage(controlDAC,[TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,-0.8],numSteps*5);
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps*5);

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps*5);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,-3,-3,-2],numSteps*5);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-3,-3,-2],numSteps*5);
delay(1)
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps*5);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,-3,-3,-1.3],numSteps);






sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,0],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-1.5,-2.5,-2],numSteps*5);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-1.5,-2,-2.5],numSteps*5);

sigDACRampVoltage(controlDAC,TopEPort,-1.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.5,-0.5,-0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1.5,-0.5,-0.5,-1.5],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-1.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-1,-1,-1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-1,-1,-2],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-2.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-1.5,-1.5,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2.5,-1.5,-1.5,-2.5],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-2.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-2,-2,-2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,TopEPort,-3.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-2.5,-2.5,-2.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3.5,-2.5,-2.5,-3.5],numSteps);

sweep1DMeasSR830({'Door'},-3.5,-2.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sweep1DMeasSR830({'Door'},0,-1,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCOutPort},1,1);


sigDACRampVoltage(controlDAC,TopEPort,-2.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-2,-2,-2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3,-2,-2,-2],numSteps);

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

sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);


%% Transfer Electrons to the other side (neg -> 0)
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleCPort},1,1); % check no electrons on otherside
% empty
sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,2,2,2],numSteps*5);

sweep1DMeasSR830({'Door'},-1,1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps*5);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleCPort},1,1); % check no electrons on otherside


sweep1DMeasSR830({'Door'},-2.5,-1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},0,1);
sweep1DMeasSR830({'Door'},2,1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCOutPort},0,1);



set33622AOutput(Awg2Ch,1,0);
set33622AOutput(Awg2Ch,2,0);

set33622AOutput(Awg2Ch,1,1);
set33622AOutput(Awg2Ch,2,1);



%% CLOSE EXPERIMENT
setVal(supplyDAC,BackMetalPort,8);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-2,-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-2,-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-2,-2,-2,-2],numSteps);

setVal(controlDAC,BlockPort,-2);

% turn off HEMTS
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[14,15,16],[0,0,0],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[0,0,0],5,0.1)

% Set all voltages to zero
setVal(supplyDAC,BackMetalPort,0);
setVal(controlDAC,BlockPort,0);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,0,0,0],numSteps);



