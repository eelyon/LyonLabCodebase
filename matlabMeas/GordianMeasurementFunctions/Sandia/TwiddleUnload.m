%% Script for unloading electron in twiddle-sense
% Run DCPinout before running this script
numSteps = 1000;
numSteps_ccd = 1000;
Vopen = 2; % holding voltage of ccd
Vclose = -2; % closing voltage of ccd

% set33622AOutput(Ag2Channel,1, 'OFF'); % turn twiddle off
% set33622AOutput(Ag2Channel,2, 'OFF'); % turn compensation off

%% Set potential gradient across twiddle-sense and unload electrons
sigDACRampVoltage(door.Device,door.Port,2,numSteps); % open door
sigDACRampVoltage(offset.Device,offset.Port,1,numSteps); % open offset

%     sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make right shield negative
sigDACRampVoltage(twiddle.Device,twiddle.Port,-2,numSteps); % make twiddle negative
sigDACRampVoltage(shieldl.Device,shieldl.Port,-1,numSteps); % make shield negative
delay(20); % wait for electrons to diffuse across twiddle to door
fprintf('Twiddle-sense unloaded\n')

% sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open ccd1
sigDACRampVoltage(offset.Device,offset.Port,Vclose,numSteps); % close offset
sigDACRampVoltage(door.Device,door.Port,Vclose,numSteps); % close door

% set33622AOutput(Ag2Channel,1, 'ON'); % turn twiddle back on
% set33622AOutput(Ag2Channel,2, 'ON'); % turn compensation back on

%     sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % set left shield back to 0V
fprintf('Twiddle-sense voltages set back\n')

sweep1DMeasSR830({'Shield'},-0.5,0.1,0.02,3,1,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield