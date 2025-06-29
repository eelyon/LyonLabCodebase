%% Get rid of electrons in twiddle/sense and put them back in (HEMT1)

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);


repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.5,-0.4,-0.4],numSteps);
sweep1DMeasSR830({'Door'},-1,0.2,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
delay(3)
sweep1DMeasSR830({'Door'},0,-1,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
sweep1DMeasSR830({'SEN'},0,-0.5,0.05,0.1,10,{SR830Twiddle},controlDAC,{SenseEPort},1,1);
sweep1DMeasSR830({'TWW'},0.3,0.3-0.4,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);

disp(i)
end

%% other side (HEMT2)
repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0.2,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.4,-0.3,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);

delay(3)
sweep1DMeasSR830({'Door'},-0.3,-1,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.4,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);
sweep1DMeasSR830({'SEN'},0,-0.3,0.05,0.1,10,{SR830TwiddleC},controlDAC,{SenseCPort},1,1);

disp(i)
end