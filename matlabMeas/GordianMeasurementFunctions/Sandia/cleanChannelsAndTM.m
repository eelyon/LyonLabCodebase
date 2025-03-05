%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Channels parallel to the 6 used ones are emptied by lifting electrons
% onto top metal through d4 and phi1_1
% Run DCPinout before running this script
numSteps = 50; % sigDACRampVoltage
numStepsCCD = 50; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.01; % 5 times time constant

Vopen = 0.7; % holding voltage of ccd
Vclose = -0.6; % closing voltage of ccd

%% Set 1st twiddle-sense positive to attract electrons from top metal
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime)
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta)
interleavedRamp(guard1_l.Device,guard1_l.Port,Vopen,numStepsRC,waitTime)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,Vopen,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD)

interleavedRamp(TM.Device,TM.Port,-2,numStepsRC,waitTime*10); delay(1)
interleavedRamp(TM.Device,TM.Port,-0.7,numStepsRC,waitTime*10)

%% Move electrons onto vertical CCD
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
interleavedRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTime)
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,delta)
interleavedRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,Vclose,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD)

% Open gates to let electrons onto vertical CCD
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)

sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD) % Move electrons onto vertical CCD

%% Move electrons downwards
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
unloadTwiddleSense1;

sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)



sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)

