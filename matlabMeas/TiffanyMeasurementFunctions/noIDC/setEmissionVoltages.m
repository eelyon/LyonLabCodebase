%% Starting up Experiment

DCMap;
numSteps = 1000;
setVal(supplyDAC,BackMetalPort,-1);

% compensation voltages
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-1,-1,-1],numSteps);

% emission voltages
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

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
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[1.97,1.98,0.7],5,0.1)

% turn off HEMTS
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[14,15,16],[0,0,0],5,0.1)
interleavedRamp([supplyDAC,supplyDAC,supplyDAC],[24,13,23],[0,0,0],5,0.1)

% compensation
compensateParasitics(SR830Twiddle,Awg2Ch,Awg2Ch,-180,180,10,0.002,0.350,0.010,0)
compensateParasitics(SR830TwiddleC,Ag2Nat,Ag2Nat,-180,180,10,0.002,0.350,0.010,0)

% Voltages for emission
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,-1,-1,-1],numSteps);

% check sommer tanner for electrons and sweep top metal
sweep1DMeasSR830({'ST'},0,-0.5,-0.05,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);
sweep1DMeasSR830({'TE'},-0.7,-1.1,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{TopEPort},1);
sweep1DMeasSR830({'TC'},-0.7,-1.1,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{TopCPort},1);

% sweep twiddle sense areas for electrons
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'Door'},-3,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);


sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,1,1,1],numSteps);

%% Get rid of electrons in twiddle/sense and put them back in
% sweep door in to get rid of electrons

repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[1,1,1],numSteps);
sweep1DMeasSR830({'Door'},-1,0.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEInPort},1,1);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.5,-0.4,-0.3],numSteps);
sweep1DMeasSR830({'Door'},-0.8,0,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEInPort},0,1);

delay(5)
sigDACRampVoltage(controlDAC,[TwiddleEPort,SenseEPort],[1,1],numSteps);
sweep1DMeasSR830({'Door'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEInPort},0,1);
sigDACRampVoltage(controlDAC,[TwiddleEPort,SenseEPort],[0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleEPort},1,1);
disp(i)
end

%% Transfer Electrons to the other side

% transfer configuration 
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[1.3,2,2,2],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[2,2,2,2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[1.5,0.5,0.1,1],numSteps);

% ST sweep on collector side
sweep1DMeasSR830({'ST'},0,-0.5,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{StmCPort},1);

% door out sweep
sweep1DMeasSR830({'Door'},-1,0.1,-0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

% big transfer
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sweep1DMeasSR830({'Door'},-1,0.5,-0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorEOutPort},0);

sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);

sweep1DMeasSR830({'Door'},-1,0.3,-0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

%% CLOSE EXPERIMENT
setVal(supplyDAC,BackMetalPort,8);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-2,-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-2,-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-2,-2,-2,-2],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-2,-2,-2,-2],numSteps);






% Set all voltages to zero
setVal(supplyDAC,BackMetalPort,0);

sigDACRampVoltage(DAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0,0],numSteps);
sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(DAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0,0],numSteps);
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,0,0],numSteps);

sigDACRampVoltage(DAC,[TfCPort,TfEPort,BEPort,BCPort],[0,0,0,0],numSteps);