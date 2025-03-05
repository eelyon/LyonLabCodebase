%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Run DCPinout before running this script
numSteps = 20; % sigDACRampVoltage
numStepsCCD = 20; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.0011; % 5 times time constant

Vopen = 1; % holding voltage of ccd
Vclose = -0.5; % closing voltage of ccd

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

interleavedRamp(TM.Device,TM.Port,-1.4,numStepsRC,waitTime*10); delay(1)
interleavedRamp(TM.Device,TM.Port,-0.7,numStepsRC,waitTime)

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
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % Electrons on phi1_3

% Open gates to let electrons onto vertical CCD
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD) % Electrons on vertical CCD
unloadTwiddleSense1;

%% Move electrons up
for n = 1:93
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vclose,numSteps)
    unloadTwiddleSense1 % Move electrons from phi_Vdown_2 out through 6 channels
end

sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)

for n = 1:4
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)

    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    unloadTwiddleSense1 % Move electrons out of twiddle-sense

    % Move electrons on phi_Vup_2
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
end

sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)

