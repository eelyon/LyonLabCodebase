%% Get rid of electrons in twiddle/sense and put them back in (HEMT1)

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);


repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
% setVal(controlDAC,DoorEInPort,0);
% setVal(controlDAC,DoorEInPort,-1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.4,-0.2,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
setVal(controlDAC,TwiddleEPort,0.5);
delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
setVal(controlDAC,TwiddleEPort,0);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.4,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
disp(i)
end


%% other side (HEMT2)
% for some reason changing StmC port loses electron signal
repeat = 3;
for i = 1:repeat
% get rid of electrons    
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0.1,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);

% let in electrons
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.4,-0.2,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps);
sweep1DMeasSR830({'TWW'},0,-0.3,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);
disp(i)
end