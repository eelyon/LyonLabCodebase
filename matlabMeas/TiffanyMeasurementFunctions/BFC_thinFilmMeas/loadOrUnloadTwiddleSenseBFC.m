%% Get rid of electrons in twiddle/sense and put them back in (HEMT1)

QDACSmoothRampVoltage(qDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],qDACrampTime);
QDACSmoothRampVoltage(qDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],qDACrampTime);


repeat = 3;
for i = 1:repeat
% get rid of electrons
STVoltage = 5;

QDACSmoothRampVoltage(qDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage+0.5,STVoltage+0.5,STVoltage+0.5],qDACrampTime);
sweep1DMeasSR830({'Door'},STVoltage-1,STVoltage,0.1,0.1,10,{SR830Top},qDAC,{DoorEInPort},1,1);
QDACSmoothRampVoltage(qDAC,DoorEInPort,STVoltage,qDACrampTime); % open door
delay(0.5)
QDACSmoothRampVoltage(qDAC,DoorEInPort,STVoltage-1,qDACrampTime); % close door
QDACSmoothRampVoltage(qDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage,STVoltage,STVoltage],qDACrampTime);

% let in electrons
QDACSmoothRampVoltage(qDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage-0.3,STVoltage-0.2,STVoltage-0.2],qDACrampTime);
sweep1DMeasSR830({'Door'},STVoltage-1,STVoltage,0.05,0.1,10,{SR830Top},qDAC,{DoorEInPort},1,1);
delay(3)
sweep1DMeasSR830({'Door'},0,-1,0.1,0.1,10,{SR830Twiddle},qDAC,{DoorEInPort},0,1);
QDACSmoothRampVoltage(qDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],qDACrampTime);
sweep1DMeasSR830({'TWW'},STVoltage,STVoltage-0.5,0.05,0.1,10,{SR830Top},qDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'SEN'},STVoltage,STVoltage-0.5,0.05,0.1,10,{SR830Top},qDAC,{SenseEPort},1,1);

disp(i)
end

%% other side (HEMT2)
repeat = 3;
for i = 1:repeat
% get rid of electrons    
STCVoltage = 0;

sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STCVoltage+0.5,STCVoltage+0.5,STCVoltage+0.5],numSteps);
sweep1DMeasSR830({'Door'},STCVoltage-1,STCVoltage,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STCVoltage,STCVoltage,STCVoltage],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[STCVoltage-0.3,STCVoltage-0.2,STCVoltage-0.2],numSteps);
sweep1DMeasSR830({'Door'},STCVoltage-1,STCVoltage,0.2,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,DoorCInPort,STCVoltage,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCInPort,STCVoltage-1,numSteps);

delay(3)
sweep1DMeasSR830({'Door'},-0.3,-1,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},STCVoltage,STCVoltage-0.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);
sweep1DMeasSR830({'SEN'},STCVoltage,STCVoltage-0.3,0.05,0.1,10,{SR830TwiddleC},controlDAC,{SenseCPort},1,1);

disp(i)
end