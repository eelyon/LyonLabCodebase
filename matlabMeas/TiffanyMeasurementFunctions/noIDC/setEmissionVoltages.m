%% Starting up Experiment

DCMap;
numSteps = 1000;
setVal(supplyDAC,BackMetalPort,-2);
setVal(controlDAC,Block1Port,-2);
setVal(controlDAC,Block2Port,-2);


% compensation voltages
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,1,1,1],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-1,-1,-1],numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-0.5,-1,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1.5,-1.5,-1.5,-3],numSteps);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-2,-2,-2],numSteps*5);


% emission voltages
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-2,-2,-2,-2],numSteps);

% emission to other side
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

% Transfer voltage (Check)
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[1,1,1,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[1.3,2,2,2],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[2,2,2,2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[2,1,0,0.5],numSteps);


% turn on HEMTs
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[14,15,16],[2,2,0.5],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[1.97,1.98,0.74],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[2,2.3,0.5],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[14,15,16],[2,2.3,0.5],5,0.1)

% turn off HEMTS
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[14,15,16],[0,0,0],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[0,0,0],5,0.1)

% compensation
compensateParasitics(SR830Twiddle,Ag2Nat,Ag2Nat,-180,180,10,0.200,0.350,0.010,0)  % HEMT1
compensateParasitics(SR830TwiddleC,Awg2Ch,Awg2Ch,-180,180,10,0.2,0.35,0.010,0)   % HEMT2

% Voltages for emission
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,-1,-1,-1],numSteps);

% check sommer tanner for electrons and sweep top metal
sweep1DMeasSR830({'ST'},-2.5,-2.9,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmEPort},1);
sweep1DMeasSR830({'ST'},0,-0.5,-0.05,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);

sweep1DMeasSR830({'ST'},0,-0.7,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmCPort},1);
sweep1DMeasSR830({'ST'},-1.5,-1.5-0.5,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmCPort},1);

sweep1DMeasSR830({'TE'},-0.7,-1.1,-0.05,0.1,10,{SR830Twiddle},controlDAC,{TopEPort},1);
sweep1DMeasSR830({'TC'},-0.7,-1.2,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{TopCPort},1);
sweep1DMeasSR830({'TC'},3.2,1.8,-0.05,0.1,10,{SR830Twiddle},controlDAC,{TopCPort},0);

% sweep twiddle sense areas for electrons
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'Door'},-3,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);

sweep1DMeasSR830({'Door'},-2.5,-1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,1,1,1],numSteps);

%% Get rid of electrons in twiddle/sense and put them back in
% sweep door in to get rid of electrons

repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.4,-0.3,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.1,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
disp(i)
end


% other side (HEMT2)
repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,0,1],numSteps);
sweep1DMeasSR830({'Door'},-1,0.1,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);


% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.4,0,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.1,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);
disp(i)
end

%% change voltage of left side
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


%% Transfer Electrons to the other side (0 -> pos)

% transfer configuration 
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[1.3,2,2,2],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[1,2,2,2],numSteps*5);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[1.5,0.5,0,0.5],numSteps*5);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEOutPort},1,1);
sweep1DMeasSR830({'Door'},2,1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCOutPort},0,1);

% set voltage back
sigDACRampVoltage(controlDAC,TopCPort,0.8,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1.5,1.5,1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0.5,1.5,1.5,0.5],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,0.3,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,1,1],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,1,1,0],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,-0.2,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-0.5,0.5,0.5,-0.5],numSteps);

sigDACRampVoltage(controlDAC,TopCPort,-0.7,numSteps*5);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleCPort},1,1);

% throw away electrons
sweep1DMeasSR830({'Door'},-1,0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCInPort},1,1);

sigDACRampVoltage(controlDAC,TfCPort,-1,numSteps*5);



set33622AOutput(Awg2Ch,1,0);
set33622AOutput(Awg2Ch,2,0);

set33622AOutput(Awg2Ch,1,1);
set33622AOutput(Awg2Ch,2,1);


% transfer configuration (flipped)
sweep1DMeasSR830({'ST'},-1.5,-2,-0.05,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-2.2,-1.5,-1.5,-1.5],numSteps*5);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1.5,-1.5,-1.5,-2.5],numSteps*5);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,-1,-1.5,-0.5],numSteps);

% ST sweep on collector side
sweep1DMeasSR830({'ST'},2,1.3,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmCPort},1);

% door out sweep
sweep1DMeasSR830({'Door'},-1,0.1,-0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

% big transfer
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sweep1DMeasSR830({'Door'},-1,0.5,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEOutPort},0);

sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);

sweep1DMeasSR830({'Door'},-1,0.3,-0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);



% Big transfer
sweep1DMeasSR830({'ST'},0,-0.5,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmEPort},1);
sweep1DMeasSR830({'ST'},2.5,2.5-0.5,-0.05,0.1,10,{SR830Twiddle},controlDAC,{StmCPort},1);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-3.2,-2.5,-2.5,-2.5],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2.5,-2.5,-2.5,-3.5],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,2.5,2.5,2.5],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1.5,-1,-1.5,-2],numSteps);





%% CLOSE EXPERIMENT
setVal(supplyDAC,BackMetalPort,8);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-2,-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-2,-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-2,-2,-2,-2],numSteps);

setVal(controlDAC,Block1Port,-2);
setVal(controlDAC,Block2Port,-2);

% turn off HEMTS
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[14,15,16],[0,0,0],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[0,0,0],5,0.1)




% Set all voltages to zero
setVal(supplyDAC,BackMetalPort,0);
setVal(controlDAC,Block1Port,0);
setVal(controlDAC,Block2Port,0);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0,0,0,0],numSteps);



