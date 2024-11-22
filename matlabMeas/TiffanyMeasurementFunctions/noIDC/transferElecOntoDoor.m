% transfer electrons onto the door gate
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-1,-0.5,-2,-2.5],numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0,numSteps);

sigDACRampVoltage(controlDAC,DoorCInPort,-3,numSteps);
sigDACRampVoltage(controlDAC,TwiddleCPort,-0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorCOutPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,SenseCPort,-3,numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,-2,numSteps);



% other way HEMT1 to HEMT2
sigDACRampVoltage(controlDAC,[TfCPort,TfEPort,BEPort,BCPort],[-0.5,-1,-2.5,-2],numSteps);

sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);

sigDACRampVoltage(controlDAC,DoorEInPort,-1.5,numSteps);
sigDACRampVoltage(controlDAC,TwiddleEPort,-0.5,numSteps);
sigDACRampVoltage(controlDAC,DoorEOutPort,0.5,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,-1.5,numSteps);

sigDACRampVoltage(controlDAC,DoorEOutPort,-2,numSteps);

sigDACRampVoltage(controlDAC,TwiddleEPort,0,numSteps);
sigDACRampVoltage(controlDAC,SenseEPort,0,numSteps);
sigDACRampVoltage(controlDAC,DoorEInPort,-1,numSteps);
