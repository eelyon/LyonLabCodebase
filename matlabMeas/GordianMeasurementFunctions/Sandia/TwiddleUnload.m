%% Script for unloading electron in twiddle-sense
% Run DCPinout before running this script
numSteps = 2;
numSteps_ccd = 100;
waitTime = 0.5;
Vopen = 0.6; % holding voltage of ccd
Vclose = -0.6; % closing voltage of ccd

interleavedRamp(TM.Device,TM.Port,-0.67,5,0.1); % make top metal less negative

%% Set potential gradient across twiddle-sense and unload electrons
% sigDACRampVoltage(ccd1.Device,ccd1.Port,2,5000); % open ccd1
interleavedRamp(door.Device,door.Port,0.6,numSteps,waitTime); % open door
interleavedRamp(offset.Device,offset.Port,0.3,numSteps,waitTime); % open offset

sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make right shield negative
sigDACRampVoltage(twiddle.Device,twiddle.Port,-2,numSteps); % make twiddle negative
interleavedRamp(shieldl.Device,shieldl.Port,-1,numSteps,waitTime); % make shield negative
interleavedRamp(sense.Device,sense.Port,-0.3,numSteps,waitTime); % make sense negative
delay(30); % wait for electrons to diffuse across twiddle to door
fprintf('Twiddle-sense unloaded\n')

interleavedRamp(offset.Device,offset.Port,-2,numSteps,waitTime); % close offset

% set33622AOutput(Ag2Channel,1, 'ON'); % turn twiddle back on
% set33622AOutput(Ag2Channel,2, 'ON'); % turn compensation back on

sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,500); % set right shield back to -2V
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,500); % set twiddle back to 0V
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back to 0V
interleavedRamp(sense.Device,sense.Port,0,numSteps,waitTime); % set sense back to 0V
fprintf('Twiddle-sense voltages set back\n')

[avgMag,avgReal,avgImag] = sweep1DMeasSR830({'Shield'},0.1,-0.4,0.01,3,1,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back