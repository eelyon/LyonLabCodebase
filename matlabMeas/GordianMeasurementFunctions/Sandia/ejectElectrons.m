%% Script for removing all electrons from device
% numSteps = 20; % set wait time after each voltage step
% numStepsRC = 10; % % set steps for slow ramp for filtered lines
% waitTimeRC = 0.0011; % set to 5 times time constant
% delta = 0.1; % for SIM900 ramp
stopVal = -2; % set stop voltage

%% Set backing plate and top metal positive then sweep ST middle gate
setSIM900Voltage(filament.Device,filament.Port,4); delay(1) % ramp filament backing plate
sigDACRamp(TM.Device,TM.Port,1,numStepsRC,waitTimeRC) % make top metal positive
delay(5)

% sweep1DMeasSR830({'ST'},0,-0.6,-0.02,1,9,{SR830ST},STM.Device,{STM.Port},0);

%% Set ST gates negative
sigDACRampVoltage(STD.Device,STD.Port,stopVal,numSteps) % Sommer-Tanner drive
sigDACRampVoltage(STS.Device,STS.Port,stopVal,numSteps) % Sommer-Tanner sense
sigDACRampVoltage(STM.Device,STM.Port,stopVal,numSteps) % Sommer-Tanner middle gate
sigDACRampVoltage(BPG.Device,BPG.Port,stopVal,numSteps) % bond pad guard

%% Set CCD gates negative
sigDACRampVoltage(d1_odd.Device,d1_odd.Port,stopVal,numSteps)
sigDACRampVoltage(d1_even.Device,d1_even.Port,stopVal,numSteps)
sigDACRampVoltage(d2.Device,d2.Port,stopVal,numSteps)
sigDACRampVoltage(d3.Device,d3.Port,stopVal,numSteps)

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,stopVal,numSteps)
sigDACRampVoltage(phi1_2.Device,phi1_2.Port,stopVal,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,stopVal,numSteps)

%% Set 1st twiddle-sense negative
sigDACRampVoltage(d4.Device,d4.Port,stopVal,numSteps)
sigDACRamp(d5.Device,d5.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(sense1_l.Device,sense1_l.Port,stopVal,numStepsRC,waitTimeRC) % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTimeRC,delta);
sigDACRamp(guard1_l.Device,guard1_l.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,stopVal,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,stopVal,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,stopVal,numSteps)
sigDACRamp(shield.Device,shield.Port,stopVal,numStepsRC,waitTimeRC)
delay(1)

%% Set 2nd twiddle-sense negative
sigDACRampVoltage(d7.Device,d7.Port,stopVal,numSteps) % door for compensation of sense 1
sigDACRamp(sense2_l.Device,sense2_l.Port,stopVal,numStepsRC,waitTimeRC); delay(1) % rampSIM900Voltage(sense2_l.Device,sense2_l.Port,-0.5,waitTimeRC,delta);
sigDACRamp(guard2_l.Device,guard2_l.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(twiddle2.Device,twiddle2.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard2_r.Device,guard2_r.Port,stopVal,numSteps)
sigDACRampVoltage(sense2_r.Device,sense2_r.Port,stopVal,numSteps)
sigDACRampVoltage(d8.Device,d8.Port,stopVal,numSteps)
delay(1)

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

%% Set electron trap
sigDACRampVoltage(d9.Device,d9.Port,stopVal,numSteps)
sigDACRampVoltage(phi2_1.Device,phi2_1.Port,stopVal,numSteps)
sigDACRampVoltage(phi2_2.Device,phi2_2.Port,stopVal,numSteps)
sigDACRampVoltage(phi2_3.Device,phi2_3.Port,stopVal,numSteps)

sigDACRamp(trap1.Device,trap1.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(trap2.Device,trap2.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(trap3.Device,trap3.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(trap4.Device,trap4.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(trap5.Device,trap5.Port,stopVal,numStepsRC,waitTimeRC)
sigDACRamp(trap6.Device,trap6.Port,stopVal,numStepsRC,waitTimeRC)
delay(1)

sigDACRamp(TM.Device,TM.Port,-2,numStepsRC,waitTimeRC) % make top metal negative
fprintf('Electrons are ejected.\n')