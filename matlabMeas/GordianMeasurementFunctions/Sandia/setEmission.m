%% This script sets all gate voltages for emission
% Run DCPinout before running this script
numSteps = 100; % sigDACRampVoltage
numStepsRC = 10; % interleavedRamp
waitTime = 0.02; % interleavedRamp
delta = 0.1; % rampSIM900Voltage
stopVal = -4;

%% Set Sommer-Tanner
interleavedRamp(TM.Device,TM.Port,-3,numStepsRC,waitTime) % ramp top metal
sigDACRampVoltage(M2S.Device,M2S.Port,-0.5,numSteps) % ramp M2 shield
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps) % ramp bond pad guard
fprintf('Top metal, M2 shield, and bond pad guard set for emission.\n')

sigDACRampVoltage(STD.Device,STD.Port,+2,numSteps) % ramp ST-Drive
sigDACRampVoltage(STS.Device,STS.Port,+2,numSteps) % ramp ST-Sense
sigDACRampVoltage(STM.Device,STM.Port,+2,numSteps) % ramp ST-Middle
fprintf('Sommer-Tanner set for emission.\n')

%% Set 1st CCD
sigDACRampVoltage(d1_odd.Device,d1_odd.Port,stopVal,numSteps)
sigDACRampVoltage(d1_even.Device,d1_even.Port,stopVal,numSteps)
sigDACRampVoltage(d2.Device,d2.Port,stopVal,numSteps)
sigDACRampVoltage(d3.Device,d3.Port,stopVal,numSteps)

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,stopVal,numSteps)
sigDACRampVoltage(phi1_2.Device,phi1_2.Port,stopVal,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,stopVal,numSteps)
fprintf('1st CCD set for emission.\n')

%% Set 1st twiddle-sense
interleavedRamp(shield.Device,shield.Port,-0.5,numStepsRC,waitTime) % shield underneath twiddle-sense
sigDACRampVoltage(d4.Device,d4.Port,stopVal,numSteps)
interleavedRamp(d5.Device,d5.Port,stopVal,numStepsRC,waitTime) % compensation
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,delta)
interleavedRamp(guard1_l.Device,guard1_l.Port,stopVal,numStepsRC,waitTime)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,stopVal,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,stopVal,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,stopVal,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,stopVal,numSteps)
fprintf('1st twiddle-sense set for emission.\n')

%% Set vertical CCD
sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,stopVal,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,stopVal,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,stopVal,numSteps)

sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,stopVal,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,stopVal,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,stopVal,numSteps)

sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,stopVal,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,stopVal,numSteps)
sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,stopVal,numSteps)
fprintf('Vertical CCD set for emission.\n')

%% Set 2nd twiddle-sense
sigDACRampVoltage(d7.Device,d7.Port,stopVal,numSteps) % door for compensation of sense 1
rampSIM900Voltage(sense2_l.Device,sense2_l.Port,-0.5,waitTime,delta)
interleavedRamp(guard2_l.Device,guard2_l.Port,stopVal,numStepsRC,waitTime)
sigDACRampVoltage(twiddle2.Device,twiddle2.Port,stopVal,numSteps)
sigDACRampVoltage(guard2_r.Device,guard2_r.Port,stopVal,numSteps)
sigDACRampVoltage(sense2_r.Device,sense2_r.Port,stopVal,numSteps)
sigDACRampVoltage(d8.Device,d8.Port,stopVal,numSteps)
fprintf('2nd twiddle-sense set for emission.\n')

%% Set electron trap
sigDACRampVoltage(d9.Device,d9.Port,stopVal,numSteps)
sigDACRampVoltage(phi2_1.Device,phi2_1.Port,stopVal,numSteps)
sigDACRampVoltage(phi2_2.Device,phi2_2.Port,stopVal,numSteps)
sigDACRampVoltage(phi2_3.Device,phi2_3.Port,stopVal,numSteps)

interleavedRamp(trap1.Device,trap1.Port,stopVal,numStepsRC,waitTime)
interleavedRamp(trap2.Device,trap2.Port,stopVal,numStepsRC,waitTime)
interleavedRamp(trap3.Device,trap3.Port,stopVal,numStepsRC,waitTime)
interleavedRamp(trap4.Device,trap4.Port,stopVal,numStepsRC,waitTime)
interleavedRamp(trap5.Device,trap5.Port,stopVal,numStepsRC,waitTime)
interleavedRamp(trap6.Device,trap6.Port,stopVal,numStepsRC,waitTime)
fprintf('Electron trap set for emission.\n')

rampSIM900Voltage(filament.Device,filament.Port,-1,waitTime,0.1) % ramp filament backing plate
fprintf('Backing plate set for emission.\n')