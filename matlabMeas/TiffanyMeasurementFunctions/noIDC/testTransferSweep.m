BCVoltages = [2.5,2.25,2,1.75,1.5,1.25,1,0.75,0.5];

for i=1:length(BCVoltages)
% make sure doorout is closed and load electrons
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);

% set thin film voltages
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,2,BCVoltages(i)],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

% make sure other sides door is open
sigDACRampVoltage(controlDAC,DoorCOutPort,3,numSteps);

% transfer electrons and close door
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
delay(2)
sigDACRampVoltage(controlDAC,DoorCOutPort,2,numSteps);

% check to see if anything was transferred 
sweep1DMeasSR830({'TWW'},3,3-0.4,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

end

sigDACRampVoltage(controlDAC,DoorCOutPort,3,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,-3,-3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-3,numSteps);

sigDACRampVoltage(controlDAC,BEPort,-2,numSteps);
sigDACRampVoltage(controlDAC,BCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-2,numSteps);


sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,1.5,1.9],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,1.5,3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,0.75,2.25],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,2,3.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,2.5,4],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,2.5,0.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,2.5,0],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,2,3.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,2,0],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,2,3.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,2,2.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,2,2.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
