sigDACRampVoltage(controlDAC,TwiddleEPort,0.2,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-1,-1,-1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-1,numSteps);


sigDACRampVoltage(controlDAC,TwiddleEPort,0.7,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0.7,numSteps);



sigDACRampVoltage(controlDAC,SenseEPort,-0.5,numSteps);


sweep1DMeasSR830({'TM'},-0.7,-1,0.05,0.1,5,{SR830Twiddle},controlDAC,{TopEPort},1,0);

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

Vbias = 3;
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias+0.5,Vbias+0.5,Vbias+0.5],numSteps);
sweep1DMeasSR830({'Door'},Vbias-1,Vbias,0.1,0.1,10,{SR830TwiddleC},controlDAC,{DoorCInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[Vbias,Vbias,Vbias],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2.5,1,1],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,0,numSteps);