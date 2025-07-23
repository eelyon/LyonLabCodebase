%% Script to set gate voltages for measurement and initialise ramping parameters
% Run DCPinout before running this script

%% Initialise ramp parameters
numSteps = 100; % sigDACRampVoltage
numStepsRC = 10; % sigDACRamp
waitTimeRC = 1100; % in microseconds
Vopen = 1; % opening voltage of CCD
Vclose = -0.8; % closing voltage of CCD, set below top metal

setSIM900Voltage(filament.Device,filament.Port,-2) % set back filament backing plate
delay(1)

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

sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps) % set bond pad guard
% CCDclean % Clean out 1st CCD

%% Set 1st twiddle-sense
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close door
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % set twiddle to 0V
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % set right shield to -2V
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps) % set right sense gate
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
% fprintf('1st twiddle-sense set for measurement\n')
delay(1)

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
% fprintf('Vertical CCD set for measurement\n')
delay(1)

%% Set 2nd twiddle-sense
sigDACRampVoltage(d7.Device,d7.Port,-2,numSteps) % door for compensation of sense 1
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRampVoltage(twiddle2.Device,twiddle2.Port,0,numSteps)
sigDACRampVoltage(guard2_r.Device,guard2_r.Port,-2,numSteps)
sigDACRampVoltage(sense2_r.Device,sense2_r.Port,Vclose,numSteps)
sigDACRampVoltage(d8.Device,d8.Port,Vclose,numSteps)
sigDACRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTimeRC)
% fprintf('2nd twiddle-sense set for measurement.\n')
delay(1)

%% Set electron trap
sigDACRampVoltage(d9.Device,d9.Port,-2,numSteps)
sigDACRampVoltage(phi2_1.Device,phi2_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi2_2.Device,phi2_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi2_3.Device,phi2_3.Port,Vclose,numSteps)

sigDACRamp(trap1.Device,trap1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(trap2.Device,trap2.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(trap3.Device,trap3.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(trap4.Device,trap4.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(trap5.Device,trap5.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(trap6.Device,trap6.Port,Vclose,numStepsRC,waitTimeRC)
% fprintf('Electron trap set for measurement.\n')
delay(1)

sigDACRamp(TM.Device,TM.Port,-0.8,numStepsRC,waitTimeRC) % ramp top metal