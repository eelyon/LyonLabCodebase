% transfer script

%% Negative HEMT2 collector side
sweepGatesforTransport(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,-2.5,'neg');
sigDACRampVoltage(controlDAC,DoorEOutPort,0,5000);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1.5,2,1.7,-1.8],numSteps);

% check no electrons
% sigDACRampVoltage(controlDAC,DoorEOutPort,-1,5000);
% sweep1DMeasSR830({'TWW'},0,-0.8,0.1,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);

sigDACRampVoltage(controlDAC,TfEPort,-1.5,5000);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,5000);
sigDACRampVoltage(controlDAC,TfEPort,2,5000);

        % sweep 
sweep1DMeasSR830({'Door'},-3.5,-2.5,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorCOutPort},1,1);
        % or fake pulse
sigDACRampVoltage(controlDAC,DoorCOutPort,-2.5,5000);
delay(1)
sigDACRampVoltage(controlDAC,DoorCOutPort,-3.5,5000);

sigDACRampVoltage(controlDAC,DoorEOutPort,-1,5000);
sweep1DMeasSR830({'TWW'},0,-0.8,0.1,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);

sweepGatesBackToZero(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,-2.5,'neg')
sigDACRampVoltage(controlDAC,DoorEOutPort,0,5000);
sigDACRampVoltage(controlDAC,BEPort,-3,5000);
sigDACRampVoltage(controlDAC,TfEPort,-2.5,5000);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,5000);




%% Positive HEMT2 collector side
sweepGatesforTransport(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,2.5,'Pos');
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[4.5,1,0.5,4],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);

sigDACRampVoltage(controlDAC,BCPort,-3,5000);
sigDACRampVoltage(controlDAC,TfCPort,-2.5,5000);
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,5000);


sweepGatesBackToZero(controlDAC,STOBiasCPort,StmCPort,STIBiasCPort,DoorCInPort,DoorCOutPort,TwiddleCPort,SenseCPort,TopCPort,2.5,'Pos');
