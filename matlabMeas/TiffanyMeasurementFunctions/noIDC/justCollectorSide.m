%% Just collector side

% compensation voltages
sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-1,-1,-1],numSteps);

% compensation
compensateParasitics(SR830Twiddle,Awg2Ch,Awg2Ch,-180,180,10,0.002,0.350,0.010,0)

% emission voltages
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-3,-3,-3,-3],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-3,-3,-3,-3],numSteps);

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[0,0,0,-1],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[1.5,1,0.5,1],numSteps);
sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[3.2,2.5,2.5,2.5],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[2.5,2.5,2.5,2.5],numSteps);

% other side (HEMT2)
repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[1,0,1],numSteps);
sweep1DMeasSR830({'Door'},-1,0.1,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);


% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.3,0,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleCPort},1,1);
disp(i)
end

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3.5,-2.5,-2.5,-3.5],numSteps);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-3,-2.6,-2.6],numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-2.5,numSteps);
delay(5)
sigDACRampVoltage(controlDAC,DoorEInPort,-3.5,numSteps);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-2.5,-2.5,-2.5],numSteps);
sweep1DMeasSR830({'Door'},-3.5,-2,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3.5,-3.5,-3.5,-1.5],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-3.5,-2.5,-2.5,-3.5],numSteps);


sweep1DMeasSR830({'Door'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorCOutPort},0,1);
sweep1DMeasSR830({'TWW'},0,-0.8,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleCPort},1,1);

%% big transfer
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[0,0,0,-1],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-2.5,-2.5,-2.5,-3.5],numSteps);
sweep1DMeasSR830({'Door'},-3.5,-2,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorEOutPort},1,0);

