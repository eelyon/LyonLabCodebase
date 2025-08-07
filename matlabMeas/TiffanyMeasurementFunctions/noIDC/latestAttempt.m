sigDACRampVoltage(controlDAC,TwiddleEPort,0.2,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);


sigDACRampVoltage(controlDAC,TwiddleEPort,0.7,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0.7,numSteps);


sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);

sigDACRampVoltage(controlDAC,SenseEPort,-0.5,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,-0.5,numSteps);

sigDACRampVoltage(controlDAC,SenseEPort,0,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,0,numSteps);

sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-0.5,numSteps);

sigDACRampVoltage(controlDAC,SenseCPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,TwiddleCPort,0.3,numSteps);


sweep1DMeasSR830({'TM'},-0.7,-1,0.05,0.1,5,{SR830Twiddle},controlDAC,{TopEPort},1,1);
sweep1DMeasSR830({'TM'},-0.7,-1,0.05,0.1,5,{SR830TwiddleC},controlDAC,{TopCPort},1,1);

sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,1.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-3,-3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.2,numSteps);

sweep1DMeasSR830({'Door'},-1,0,0.05,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sweep1DMeasSR830({'TFE'},0,-0.5,0.1,0.1,10,{SR830Twiddle},supplyDAC,{TfEPort},0,1);

sweep1DMeasSR830({'TWW'},2.5,2.5-0.4,0.05,0.1,10,{SR830TwiddleC},controlDAC,{TwiddleCPort},1,1);

Vbias = -2.5;
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias+0.5,Vbias+0.5,Vbias+0.5],numSteps);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias-0.3,Vbias-0.2,Vbias-0.1],numSteps);

sweep1DMeasSR830({'Door'},Vbias-1,Vbias,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,DoorCInPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,Vbias-1,numSteps);


sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias,Vbias,Vbias],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,1,1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);




sigDACRampVoltage(controlDAC,BCPort,0.4,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,BCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-2,numSteps);
delay(1)
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCInPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);


sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,BEPort,2,numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEOutPort},1,1);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
delay(5)
sigDACRampVoltage(controlDAC,BEPort,-2,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);


sigDACRampVoltage(controlDAC,BCPort,2.5,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,1,numSteps);
sigDACRampVoltage(controlDAC,BEPort,4,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,5,numSteps);

sigDACRampVoltage(controlDAC,DoorEOutPort,3,numSteps);

sigDACRampVoltage(controlDAC,BCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,BEPort,-3,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-3,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2,numSteps);



Vbias = 2.5;
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[Vbias+0.5,Vbias+0.5,Vbias+0.5],numSteps);

% sweep1DMeasSR830({'Door'},Vbias-1,Vbias,0.1,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sigDACRampVoltage(controlDAC,DoorEInPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,Vbias-1,numSteps);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[Vbias,Vbias,Vbias],numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps);


sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0,0,0],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorEOutPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,0.3,numSteps);

sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);




sigDACRampVoltage(controlDAC,DoorCOutPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,SenseCPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,TwiddleCPort,0.3,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,0.3,numSteps);


sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);
sigDACRampVoltage(controlDAC,SenseCPort,0,numSteps);
sigDACRampVoltage(controlDAC,TwiddleCPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);


sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,1.9,1.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,-2,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);


% clean thin film on HEMT2 side
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0.7,0.7,0.7],numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,-2,0.4],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-2,-2,-2],numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);

for i = 1:5
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,1.9,2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-2,1.9,2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-2,1.9,-2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,-2,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
end



sigDACRampVoltage(controlDAC,DoorEInPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,Vbias-1,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,2,2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,2,2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,2,-2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,-2,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);

sweep1DMeasSR830({'TWW'},0.5,0.5-0.4,0.05,0.1,10,{SR830Twiddle},controlDAC,{TwiddleEPort},1,1);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,-3,-3],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,1,numSteps);



sigDACRampVoltage(controlDAC,[TfCPort,BCPort],[3,1],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BCPort],[2,0],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BCPort],[1,-1],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BCPort],[0,-2],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BCPort],[-1,-3],numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,TfCPort,-3,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,-1,0.5],numSteps);



sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,0.4,1.9],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);



sigDACRampVoltage(controlDAC,DoorEInPort,2.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,1.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,2.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[0.5,2,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,2,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-2,-0.5],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

% clean emitter side
sigDACRampVoltage(controlDAC,DoorEInPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,Vbias-1,numSteps);

sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);

% let electrons into collector side and open door
sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,-2,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);


%% timing 
% set door voltage parameters
set33220InvertOutput(AwgTwiddle,1);           % invert the output so high is the default state

set33220VoltageHighAndLow(AwgTwiddle,-3,2)    % TfC gate
set33220VoltageHighAndLow(AwgComp,-1,1)     % DoorEOut gate

set33220VoltageLow(AwgComp, -1);     % close DoorEOut gate
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps); % load electrons
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,-2,-2],numSteps);
set33220VoltageLow(AwgComp, 0.28);     % open DoorEOut gate to let electrons out
set33220VoltageLow(AwgComp, -1);       % close DoorEOut gate
set33220VoltageLow(AwgComp, -0.5);     % close DoorEOut gate
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);
send33220Trigger(AwgTwiddle)
set33220VoltageLow(AwgComp, -1);       % close DoorEOut gate


sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,-2,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,-0.5,1],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,-0.5,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);


sigDACRampVoltage(controlDAC,TwiddleEPort,0,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,-0.5,1],numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-3,-0.5,-3],numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-0.5,numSteps);


%% timed version
sigDACRampVoltage(controlDAC,TwiddleEPort,0,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);
set33220VoltageHighAndLow(AwgComp,-1,0);    % TfC gate
sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,BEPort,-0.5,numSteps);
set33220VoltageLow(AwgComp, -0.1);
set33220VoltageLow(AwgComp, -1);
set33220VoltageLow(AwgComp, -0.1);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0.5,numSteps);
set33220VoltageHighAndLow(AwgComp,-0.5,1);
send33220Trigger(AwgTwiddle)



Vbias = 2.5;
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias+0.5,Vbias+0.5,Vbias+0.5],numSteps);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias-0.3,Vbias-0.2,Vbias-0.1],numSteps);

sigDACRampVoltage(controlDAC,DoorCInPort,Vbias-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,Vbias,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,0.4,1.9],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,Vbias-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);


sigDACRampVoltage(controlDAC,DoorEInPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);

sigDACRampVoltage(controlDAC,DoorCInPort,Vbias,numSteps);
sigDACRampVoltage(controlDAC,DoorCInPort,Vbias-1,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,Vbias,numSteps);
delay(1)
sigDACRampVoltage(controlDAC,DoorCOutPort,Vbias-1,numSteps);



sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,0.4,1.9],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-2,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-2,-2,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,2,numSteps);
