numSteps = 500; % sigDACRampVoltage
numStepsCCD = 500; % sigDACRampVoltage
numStepsRC = 2; % interleavedRamp
waitTime = 0.5; % 5 times time constant

Vclose = -1.5; % closing voltage of ccd

sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps);
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps) % ramp ST-Drive
sigDACRampVoltage(STS.Device,STS.Port,0,numSteps) % ramp ST-Sense
sigDACRampVoltage(STM.Device,STM.Port,0,numSteps) % ramp ST-Middle
sigDACRampVoltage(STG.Device,STG.Port,0,numSteps) % ramp Sommer-Tanner (left) guard

sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numStepsCCD) % close ccd1
sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numStepsCCD) % close ccd2
sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numStepsCCD) % close ccd3
sigDACRampVoltage(door.Device,door.Port,-2,numSteps); % close door

sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numStepsRC,waitTime); % set left shield back
interleavedRamp(sense.Device,sense.Port,0,numStepsRC,waitTime); % set sense back to 0V
interleavedRamp(offset.Device,offset.Port,-2,numStepsRC,waitTime); % close offset
delay(2);

sweep1DMeasSR830Fast({'Shield'},0.2,-2,0.2,3,5,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
interleavedRamp(shieldl.Device,shieldl.Port,startShield,numStepsRC,waitTime) % set left shield back