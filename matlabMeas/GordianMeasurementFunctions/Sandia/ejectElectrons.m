%% Script for removing all electrons from device
numSteps = 500; % set wait time after each voltage step
numSteps_RC = 2; % % set steps for slow ramp for filtered lines
waitTime = 0.5; % set to 5 times time constant
stopVal = -2; % set stop voltage
delayTime = 1; % time before next step

%% Set backing plate and top metal positive then sweep ST middle gate
sigDACRampVoltage(filament.Device,filament.Port,5,numSteps); % make backing plate positive
interleavedRamp(TM.Device,TM.Port,1,numSteps_RC,waitTime); % make top metal positive

% sweep1DMeasSR830({'ST'},0,-0.6,-0.02,1,9,{SR830ST},STM.Device,{STM.Port},0);
delay(5);

%% Set ST gates negative
sigDACRampVoltage(STD.Device,STD.Port,stopVal,numSteps); % Sommer-Tanner drive
sigDACRampVoltage(STS.Device,STS.Port,stopVal,numSteps); % Sommer-Tanner sense
sigDACRampVoltage(STM.Device,STM.Port,stopVal,numSteps); % Sommer-Tanner middle gate
sigDACRampVoltage(STG.Device,STG.Port,-1,numSteps); % Sommer-Tanner (left) guard
sigDACRampVoltage(M2S.Device,M2S.Port,-0.5,numSteps); % M2 shield
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps); % bond pad guard

%% Set CCD gates negative
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,stopVal,numSteps);
sigDACRampVoltage(d2_ccd.Device,d2_ccd.Port,stopVal,numSteps);
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,stopVal,numSteps);
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,stopVal,numSteps);

sigDACRampVoltage(ccd1.Device,ccd1.Port,stopVal,numSteps);
sigDACRampVoltage(ccd2.Device,ccd2.Port,stopVal,numSteps);
sigDACRampVoltage(ccd3.Device,ccd3.Port,stopVal,numSteps);

%% Set twiddle gates negative
sigDACRampVoltage(door.Device,door.Port,stopVal,numSteps);
interleavedRamp(offset.Device,offset.Port,stopVal,numSteps_RC,waitTime);
interleavedRamp(sense.Device,sense.Port,-0.5,numSteps_RC,waitTime);
interleavedRamp(shieldl.Device,shieldl.Port,stopVal,numSteps_RC,waitTime);
sigDACRampVoltage(twiddle.Device,twiddle.Port,stopVal,numSteps);
sigDACRampVoltage(shieldr.Device,shieldr.Port,stopVal,numSteps);
interleavedRamp(shield.Device,shield.Port,stopVal,numSteps_RC,waitTime);
delay(1);

interleavedRamp(TM.Device,TM.Port,stopVal,numSteps_RC,waitTime); % make top metal negative
fprintf('Electrons are ejected.\n')