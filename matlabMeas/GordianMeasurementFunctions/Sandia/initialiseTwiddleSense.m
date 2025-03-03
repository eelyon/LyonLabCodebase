numSteps = 500; % sigDACRampVoltage
numStepsCCD = 500; % sigDACRampVoltage
numStepsRC = 2; % interleavedRamp
waitTime = 0.5; % 5 times time constant

Vclose = -0.6; % closing voltage of ccd

interleavedRamp(TM.Device,TM.Port,-1,numStepsRC,waitTime); % make top metal less negative

sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps);
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps) % ramp ST-Drive
% rampSIM900Voltage(STS.Device,STS.Port,0,waitTime,0.5) % ramp ST-Sense
sigDACRampVoltage(STM.Device,STM.Port,0,numSteps) % ramp ST-Middle

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD) % close ccd1
sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numStepsCCD) % close ccd2
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD) % close ccd3
sigDACRampVoltage(d4.Device,d4.Port,-2,numSteps); % close door

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps); % set right shield back to -2V
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps); % set twiddle back to 0V
interleavedRamp(guard1_l.Device,guard1_l.Port,0.2,numStepsRC,waitTime); % set left shield back
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,0.1); % set sense back to 0V
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime); % close offset
delay(2);

sweep1DMeasSR830Fast({'Guard'},0.2,-1.2,0.2,3,5,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1); % sweep shield
interleavedRamp(guard1_l.Device,guard1_l.Port,0.2,numStepsRC,waitTime) % set left shield back