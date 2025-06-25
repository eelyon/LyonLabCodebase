%% Script to set gate voltages for measurement and initialise ramping parameters
% Run DCPinout before running this script

%% Initialise ramp parameters
numSteps = 100; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.0011; % interleavedRamp
delta = 0.5; % rampSIM900Voltage
Vopen = 1; % opening voltage of CCD
Vclose = -0.6; % closing voltage of CCD, set below top metal

setSIM900Voltage(filament.Device,filament.Port,0); delay(1) % ramp filament backing plate

%% Set Sommer-Tanner
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps) % ramp ST-Drive
sigDACRampVoltage(STS.Device,STS.Port,0,numSteps) % ramp ST-Sense
sigDACRampVoltage(STM.Device,STM.Port,0,numSteps) % ramp ST-Middle

%% Set 1st CCD
sigDACRampVoltage(d1_odd.Device,d1_odd.Port,Vclose,numSteps)
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps)
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps)
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps)

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
delay(1)

interleavedRamp(TM.Device,TM.Port,-0.8,numStepsRC,waitTime) % ramp top metal
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps) % set bond pad guard
% CCDclean % Clean out 1st CCD

%% Set 1st twiddle-sense
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime) % close door
interleavedRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTime) % set left shield back
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % set twiddle to 0V
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % set right shield to -2V
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps) % set right sense gate
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
setSIM900Voltage(sense1_l.Device,sense1_l.Port,0); delay(1) % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta); % set sense to 0V
% fprintf('1st twiddle-sense set for measurement\n'); delay(1)

%% Set vertical CCD
sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)

sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,Vclose,numSteps)
% fprintf('Vertical CCD set for measurement\n'); delay(1)

% %% Set 2nd twiddle-sense
% sigDACRampVoltage(d7.Device,d7.Port,-2,numSteps) % door for compensation of sense 1
% interleavedRamp(guard2_l.Device,guard2_l.Port,0.2,numStepsRC,waitTime)
% sigDACRampVoltage(twiddle2.Device,twiddle2.Port,0,numSteps)
% sigDACRampVoltage(guard2_r.Device,guard2_r.Port,-2,numSteps)
% sigDACRampVoltage(sense2_r.Device,sense2_r.Port,Vclose,numSteps)
% sigDACRampVoltage(d8.Device,d8.Port,Vclose,numSteps)
% rampSIM900Voltage(sense2_l.Device,sense2_l.Port,0,waitTime,delta)
% fprintf('2nd twiddle-sense set for measurement.\n')

% %% Set electron trap
% sigDACRampVoltage(d9.Device,d9.Port,-2,numSteps)
% sigDACRampVoltage(phi2_1.Device,phi2_1.Port,Vclose,numSteps)
% sigDACRampVoltage(phi2_2.Device,phi2_2.Port,Vclose,numSteps)
% sigDACRampVoltage(phi2_3.Device,phi2_3.Port,Vclose,numSteps)
% 
% interleavedRamp(trap1.Device,trap1.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap2.Device,trap2.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap3.Device,trap3.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap4.Device,trap4.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap5.Device,trap5.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap6.Device,trap6.Port,stopVal,numStepsRC,waitTime)
% fprintf('Electron trap set for measurement.\n')