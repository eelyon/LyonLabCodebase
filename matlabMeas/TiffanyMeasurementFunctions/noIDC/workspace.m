sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,3,0],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,2.5,0],numSteps);

sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,2,0.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);

sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0.5,0.5,-1],numSteps);


% HEMT1 side positive
sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[1.3,2,2,2],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[1,2,2,1],numSteps);

% tilt thin film area
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,1.4,0.3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,1.5,numSteps);

% transfer electrons from HEMT2 to HEMT1 side
sweep1DMeasSR830({'Door'},-1,0.5,0.05,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);

% measure electrons
sweep1DMeasSR830({'ST'},2,2-0.5,-0.05,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);
sweep1DMeasSR830({'ST'},2,2-0.2,-0.01,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);


% HEMT1 side back to zero
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[1.3,2,2,2],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[1,2,2,1],numSteps);

% sweep gates back to zero
sweepGatesBackToZero(controlDAC,STOBiasEPort,StmEPort,STIBiasEPort,DoorEInPort,DoorEOutPort,TwiddleEPort,SenseEPort,TopEPort,2,'Pos')

sweep1DMeasSR830({'ST'},0,-0.2,-0.01,0.1,10,{SR830Twiddle},controlDAC,{StmEPort},1);

sweep1DMeasSR830({'TWW'},0,-0.3,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleEPort},1,1);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,0,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);

sigDACRampVoltage(supplyDAC,TfEPort,1.5,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,1.2,0.2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,1.5,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,-1,-1],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[1.5,0.3,1.3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[1.5,-3,1.3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-0.5,numSteps);


% clean thin film region
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[STVoltage+0.5,STVoltage+0.5,STVoltage+0.5],numSteps);

for i = 1:10
sigDACRampVoltage(controlDAC,DoorEInPort,2.5,numSteps);
delay(2)
sigDACRampVoltage(controlDAC,DoorEInPort,1.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps);
delay(5)
sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);
end

sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
delay(2)
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);


% pulling electrons somehow from thin film
for i = 1:10
sigDACRampVoltage(controlDAC,DoorEInPort,2,numSteps);
delay(2)
sigDACRampVoltage(controlDAC,DoorEInPort,1.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,1.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);
end

sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);


sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[2.5,2.5,2.5],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[1.5,2.5,2.5,1.5],numSteps);
sigDACRampVoltage(controlDAC,TopEPort,1.8,numSteps);

% load electrons into HEMT2 side
sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
%clean electrons in HEMT1 side
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage,numSteps); % open door
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage-1,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorEOutPort,2,numSteps);
delay(5)
sigDACRampVoltage(controlDAC,DoorEOutPort,1,numSteps);

% transfer electron packet
sweep1DMeasSR830({'Door'},-1,0.5,0.2,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);

% quick transfer
sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
delay(2)
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
delay(1)
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);
delay(5)
sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);

% clean HEMT2 side
for i = 1:10
sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
delay(2)
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
delay(5)
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);
end

% send electron packet from HEMT1 side
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage,numSteps); % open door
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage-1,numSteps); % close door
sweep1DMeasSR830({'Door'},-3.5,-2.5,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);

sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage,numSteps); % open door
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage-1,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorCOutPort,1,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorEOutPort,-2.5,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorEOutPort,-3.5,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorCOutPort,-0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0,-2.1,-0.1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0,-3,-0.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0,-3,-0.5],numSteps);

sigDACRampVoltage(controlDAC,TfCPort,0,numSteps);

sweep1DMeasSR830({'Door'},1,0,0.2,0.1,10,{SR830TwiddleC},controlDAC,{DoorCOutPort},0,1);

sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps); % close door

sigDACRampVoltage(controlDAC,DoorEOutPort,4,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorEOutPort,3,numSteps); % close door

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps); % close door


sweep1DMeasSR830({'TFE'},3.5,1.5,0.1,0.1,10,{SR830Twiddle},supplyDAC,{TfEPort},0,1);


sigDACRampVoltage(controlDAC,DoorEOutPort,4,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorCInPort,STCVoltage,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorCInPort,STCVoltage-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);  % close door
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps); % close door
sigDACRampVoltage(controlDAC,DoorEOutPort,3,numSteps);  % close door

sigDACRampVoltage(supplyDAC,TfEPort,3.5,numSteps);


sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage,numSteps); % open door
sigDACRampVoltage(controlDAC,DoorEInPort,STVoltage-1,numSteps); 
sigDACRampVoltage(controlDAC,DoorEOutPort,4,numSteps);  % close door
delay(3)
sigDACRampVoltage(controlDAC,DoorEOutPort,3,numSteps);



sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);  % close door
delay(3)
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
