%% Script for removing all electrons from device
DCPinout; % load DC pinout  script
deltaVal = 0.2; % set step size
numSteps = 100; % set wait time after each voltage step
stopVal = -2; % set stop voltage
delayTime = 1; % time before next step

%% Set backing plate and top metal positive then sweep ST middle gate
sigDACRampVoltage(fil.Device,fil.Port,3,numSteps); % make backing plate positive
sigDACRampVoltage(TM.Device,TM.Port,1,numSteps); % make top metal positive

sweep1DMeasSR830({'ST'},0,-0.6,-0.02,1,9,{SR830ST},STM.Device,{STM.Port},1);
delay(1);

%% Set ST gates negative
sigDACRampVoltage(STD.Device,STD.Port,stopVal,numSteps); % Sommer-Tanner drive
sigDACRampVoltage(STS.Device,STS.Port,stopVal,numSteps); % Sommer-Tanner sense
sigDACRampVoltage(STM.Device,STM.Port,stopVal,numSteps); % Sommer-Tanner middle gate
sigDACRampVoltage(STG.Device,STG.Port,-1,numSteps); % Sommer-Tanner (left) guard
sigDACRampVoltage(M2S.Device,M2S.Port,-0.5,numSteps); % M2 shield
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps); % bond pad guard
delay(1);

%% Set CCD gates negative
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,stopVal,numSteps);
sigDACRampVoltage(d2_ccd.Device,d2_ccd.Port,stopVal,numSteps);
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,stopVal,numSteps);
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,stopVal,numSteps);
delay(1);

sigDACRampVoltage(ccd1.Device,ccd1.Port,stopVal,numSteps);
sigDACRampVoltage(ccd2.Device,ccd2.Port,stopVal,numSteps);
sigDACRampVoltage(ccd3.Device,ccd3.Port,stopVal,numSteps);
delay(1);

%% Set twiddle gates negative
sigDACRampVoltage(door.Device,door.Port,stopVal,numSteps);
sigDACRampVoltage(shieldl.Device,shieldl.Port,stopVal,numSteps);
sigDACRampVoltage(twiddle.Device,twiddle.Port,stopVal,numSteps);
sigDACRampVoltage(shieldr.Device,shieldr.Port,stopVal,numSteps);
% sigDACRampVoltage(sense.Device,sense.Port,stopVal,numSteps);
sigDACRampVoltage(offset.Device,offset.Port,stopVal,numSteps);
sigDACRampVoltage(shield.Device,shield.Port,stopVal,numSteps);
delay(1);

sigDACRampVoltage(TM.Device,TM.Port,stopVal,numSteps); % make top metal negative
fprintf('Electrons are ejected.\n')