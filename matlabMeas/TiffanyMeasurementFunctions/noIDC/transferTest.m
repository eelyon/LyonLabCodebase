%% HEMT2 side transfer to thin film and back check
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[0.5,-2,-2,-3],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-1.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,TfCPort,0.5,numSteps);

%% HEMT1 side transfer to thin film and back check
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[3,0.5,-1,-1],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,BEPort,-1.5,numSteps);
sigDACRampVoltage(controlDAC,TfEPort,-0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-2,numSteps);

sigDACRampVoltage(controlDAC,TfEPort,0.5,numSteps);


%% transfer from HEMT2 to HEMT1 side
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1.5,-0.5,-1,-2],numSteps);
sweepGatesforTransport(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,-2,'neg');
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);

% let in electrons into twiddle sense area
for i = 1:6
STVoltage = getVal(controlDAC,STIBiasCPort);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STVoltage-0.3,STVoltage-0.2,STVoltage-0.2],numSteps);

sigDACRampVoltage(controlDAC,DoorCInPort,STVoltage,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCInPort,STVoltage-1,numSteps);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STVoltage,STVoltage,STVoltage],numSteps);
% open the door
sigDACRampVoltage(controlDAC,DoorCOutPort,-1.5,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCOutPort,-3,numSteps);
fprintf(['hihi',num2str(i),'\n'])
end