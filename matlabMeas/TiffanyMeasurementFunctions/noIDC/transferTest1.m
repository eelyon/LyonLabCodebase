%% shoot out packets of electrons onto the thin film from HEMT1
for i = 1:3
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[-0.4,-0.2,-0.2],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);

delay(3)
sweep1DMeasSR830({'Door'},0,-0.8,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},0,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);

% sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[3,0.5,-1,-1],numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
delay(1)
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
fprintf(['hi',num2str(i),'\n'])
end

%% get electrons back from the thin film
for i=1:3
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0.5,0.5,0.5],numSteps);
sweep1DMeasSR830({'Door'},-1,0,0.2,0.1,10,{SR830Twiddle},controlDAC,{DoorEInPort},1,1);
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[3,0.5,-1,-1],numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);
% sigDACRampVoltage(controlDAC,TfCPort,-2,numSteps);
sigDACRampVoltage(controlDAC,BEPort,-1.5,numSteps);
sigDACRampVoltage(controlDAC,TfEPort,-0.5,numSteps);
delay(3)
sigDACRampVoltage(controlDAC,DoorEOutPort,-1,numSteps);
fprintf(['hey',num2str(i),'\n'])

end