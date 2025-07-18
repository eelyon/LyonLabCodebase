%% Script for moving electrons out of twiddle-sense2 onto d4 and back
%% Purpose is to see if I can retain my electrons in the channels or if I loose/gain along the way
numSteps = 50; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.002; % 5 times time constant
Vopen = 1;
Vclose = -0.8;

interleavedRamp(d7.Device,d7.Port,0.2,numStepsRC,waitTime) % door for compensation of sense 1
interleavedRamp(twiddle2.Device,twiddle2.Port,Vclose,numStepsRC,waitTime)
interleavedRamp(guard2_l.Device,guard2_l.Port,Vclose,numStepsRC,waitTime)
interleavedRamp(sense2_l.Device,sense2_l.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,0.4,numSteps)
interleavedRamp(d7.Device,d7.Port,Vclose,numStepsRC,waitTime) % door for compensation of sense 1
sigDACRampVoltage(d4.Device,d4.Port,0.6,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,0.8,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)

interleavedRamp(twiddle2.Device,twiddle2.Port,0,numStepsRC,waitTime)
interleavedRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTime)
interleavedRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTime)
interleavedRamp(d7.Device,d7.Port,-2,numStepsRC,waitTime)

sweep1DMeasSR830({'Guard'},0,-2,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
interleavedRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTime)
delay(1);

sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
interleavedRamp(d7.Device,d7.Port,Vopen,numStepsRC,waitTime) % door for compensation of sense 1
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
% sigDACRampVoltage(sense2_l.Device,sense2_l.Port,Vopen,numSteps)
interleavedRamp(d7.Device,d7.Port,-2,numStepsRC,waitTime)
% sigDACRampVoltage(sense2_l.Device,sense2_l.Port,0,numSteps)

sweep1DMeasSR830({'Guard'},0,-2,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
interleavedRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTime)