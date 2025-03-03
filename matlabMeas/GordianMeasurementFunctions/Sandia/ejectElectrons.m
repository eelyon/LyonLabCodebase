%% Script for removing all electrons from device
numSteps = 500; % set wait time after each voltage step
numSteps_RC = 5; % % set steps for slow ramp for filtered lines
waitTime = 0.1; % set to 5 times time constant
stopVal = 0; % set stop voltage
delayTime = 1; % time before next step

%% Set backing plate and top metal positive then sweep ST middle gate
rampSIM900Voltage(filament.Device,filament.Port,5,waitTime,0.5) % ramp filament backing plate
interleavedRamp(TM.Device,TM.Port,1,numSteps_RC,waitTime); % make top metal positive
delay(10);

% sweep1DMeasSR830({'ST'},0,-0.6,-0.02,1,9,{SR830ST},STM.Device,{STM.Port},0);

%% Set ST gates negative
sigDACRampVoltage(STD.Device,STD.Port,stopVal,numSteps); % Sommer-Tanner drive
% rampSIM900Voltage(STS.Device,STS.Port,stopVal,waitTime,0.1) % Sommer-Tanner sense
sigDACRampVoltage(STM.Device,STM.Port,stopVal,numSteps); % Sommer-Tanner middle gate
sigDACRampVoltage(M2S.Device,M2S.Port,-0.5,numSteps); % M2 shield
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps); % bond pad guard

%% Set CCD gates negative
sigDACRampVoltage(d1_odd.Device,d1_odd.Port,stopVal,numSteps);
sigDACRampVoltage(d1_even.Device,d1_even.Port,stopVal,numSteps);
sigDACRampVoltage(d2.Device,d2.Port,stopVal,numSteps);
sigDACRampVoltage(d3.Device,d3.Port,stopVal,numSteps);

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,stopVal,numSteps);
sigDACRampVoltage(phi1_2.Device,phi1_2.Port,stopVal,numSteps);
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,stopVal,numSteps);

%% Set twiddle gates negative
sigDACRampVoltage(d4.Device,d4.Port,stopVal,numSteps);
interleavedRamp(d5.Device,d5.Port,stopVal,numSteps_RC,waitTime);
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,0.1)
interleavedRamp(guard1_l.Device,guard1_l.Port,stopVal,numSteps_RC,waitTime);
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,stopVal,numSteps);
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,stopVal,numSteps);
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,stopVal,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,stopVal,numSteps)
interleavedRamp(shield.Device,shield.Port,stopVal,numSteps_RC,waitTime);
delay(1);

interleavedRamp(TM.Device,TM.Port,stopVal,numSteps_RC,waitTime); % make top metal negative
fprintf('Electrons are ejected.\n')