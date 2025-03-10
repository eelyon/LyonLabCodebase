%% Set all gates to 0V
numSteps = 20; % set wait time after each voltage step
stopVal = 0;

sigDACSetChannels(controlDAC,stopVal)
sigDACSetChannels(supplyDAC,stopVal)
rampSIM900Voltage(filament.Device,filament.Port,stopVal,waitTime,delta)
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta)
rampSIM900Voltage(sense2_l.Device,sense2_l.Port,0,waitTime,delta)
fprintf('All gates set to 0V.\n')

% %% Set backing plate and top metal positive then sweep ST middle gate
% rampSIM900Voltage(filament.Device,filament.Port,stopVal,waitTime,delta) % ramp filament backing plate
% interleavedRamp(TM.Device,TM.Port,stopVal,numSteps_RC,waitTime) % make top metal positive
% 
% %% Set ST gates negative
% sigDACRampVoltage(STD.Device,STD.Port,stopVal,numSteps) % Sommer-Tanner drive
% sigDACRampVoltage(STS.Device,STS.Port,stopVal,numSteps) % Sommer-Tanner sense
% sigDACRampVoltage(STM.Device,STM.Port,stopVal,numSteps) % Sommer-Tanner middle gate
% sigDACRampVoltage(M2S.Device,M2S.Port,stopVal,numSteps) % ramp M2 shield
% sigDACRampVoltage(BPG.Device,BPG.Port,stopVal,numSteps) % bond pad guard
% 
% %% Set CCD gates negative
% sigDACRampVoltage(d1_odd.Device,d1_odd.Port,stopVal,numSteps)
% sigDACRampVoltage(d1_even.Device,d1_even.Port,stopVal,numSteps)
% sigDACRampVoltage(d2.Device,d2.Port,stopVal,numSteps)
% sigDACRampVoltage(d3.Device,d3.Port,stopVal,numSteps)
% 
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,stopVal,numSteps)
% sigDACRampVoltage(phi1_2.Device,phi1_2.Port,stopVal,numSteps)
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,stopVal,numSteps)
% 
% %% Set 1st twiddle-sense negative
% sigDACRampVoltage(d4.Device,d4.Port,stopVal,numSteps)
% interleavedRamp(d5.Device,d5.Port,stopVal,numSteps_RC,waitTime)
% rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta)
% interleavedRamp(guard1_l.Device,guard1_l.Port,stopVal,numSteps_RC,waitTime)
% sigDACRampVoltage(twiddle1.Device,twiddle1.Port,stopVal,numSteps)
% sigDACRampVoltage(guard1_r.Device,guard1_r.Port,stopVal,numSteps)
% sigDACRampVoltage(sense1_r.Device,sense1_r.Port,stopVal,numSteps)
% sigDACRampVoltage(d6.Device,d6.Port,stopVal,numSteps)
% interleavedRamp(shield.Device,shield.Port,stopVal,numSteps_RC,waitTime)
% 
% %% Set 2nd twiddle-sense negative
% sigDACRampVoltage(d7.Device,d7.Port,stopVal,numSteps) % door for compensation of sense 1
% rampSIM900Voltage(sense2_l.Device,sense2_l.Port,0,waitTime,delta)
% interleavedRamp(guard2_l.Device,guard2_l.Port,stopVal,numStepsRC,waitTime)
% sigDACRampVoltage(twiddle2.Device,twiddle2.Port,stopVal,numSteps)
% sigDACRampVoltage(guard2_r.Device,guard2_r.Port,stopVal,numSteps)
% sigDACRampVoltage(sense2_r.Device,sense2_r.Port,stopVal,numSteps)
% sigDACRampVoltage(d8.Device,d8.Port,stopVal,numSteps)
% 
% %% Set vertical CCD
% sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,stopVal,numSteps)
% sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,stopVal,numSteps)
% sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,stopVal,numSteps)
% 
% sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,stopVal,numSteps)
% sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,stopVal,numSteps)
% sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,stopVal,numSteps)
% 
% sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,stopVal,numSteps)
% sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,stopVal,numSteps)
% sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,stopVal,numSteps)
% 
% %% Set electron trap
% sigDACRampVoltage(d9.Device,d9.Port,stopVal,numSteps)
% sigDACRampVoltage(phi2_1.Device,phi2_1.Port,stopVal,numSteps)
% sigDACRampVoltage(phi2_2.Device,phi2_2.Port,stopVal,numSteps)
% sigDACRampVoltage(phi2_3.Device,phi2_3.Port,stopVal,numSteps)
% 
% interleavedRamp(trap1.Device,trap1.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap2.Device,trap2.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap3.Device,trap3.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap4.Device,trap4.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap5.Device,trap5.Port,stopVal,numStepsRC,waitTime)
% interleavedRamp(trap6.Device,trap6.Port,stopVal,numStepsRC,waitTime)
% fprintf('All gates set to 0V.\n')