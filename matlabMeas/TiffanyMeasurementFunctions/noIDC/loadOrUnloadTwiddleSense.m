%% Get rid of electrons in twiddle/sense and put them back in (HEMT1)

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);


repeat = 3;
for i = 1:repeat
% get rid of electrons
STVoltage = 0;
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage+0.5,STVoltage+0.5,STVoltage+0.5],numSteps);
sweep1DMeasSR830({'Door'},STVoltage-1,STVoltage,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage,numSteps); % open door
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage-1,numSteps); % close door
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage,STVoltage,STVoltage],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage-0.4,STVoltage-0.3,STVoltage-0.3],numSteps);
sweep1DMeasSR830({'Door'},STVoltage-1,STVoltage,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
delay(3)
sweep1DMeasSR830({'Door'},0,-1,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},STVoltage,STVoltage-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'SEN'},STVoltage,STVoltage-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{SenseEPort},1,1);

disp(i)
end

%% other side (HEMT2)
repeat = 3;
for i = 1:repeat
% get rid of electrons    
STCVoltage = 0;

sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0.2,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.4,-0.3,-0.3],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);

delay(3)
sweep1DMeasSR830({'Door'},-0.3,-1,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.4,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);
sweep1DMeasSR830({'SEN'},0,-0.3,0.05,0.1,10,{SR830TwiddleC},controlDAC,{SenseCPort},1,1);

disp(i)
end