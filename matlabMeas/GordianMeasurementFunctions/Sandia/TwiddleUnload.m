%% Script for unloading electron in twiddle-sense
% Run DCPinout before running this script
numSteps = 1000;
Vopen = 2; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

% set33622AOutput(Ag2Channel,1, 'OFF'); % turn twiddle off
% set33622AOutput(Ag2Channel,2, 'OFF'); % turn compensation off

%% Set potential gradient across twiddle-sense and unload electrons
sigDACRampVoltage(twiddle.Device,twiddle.Port,-0.4,numSteps); % make twiddle slightly negative
% sweep1DMeasSR830({'Twiddle'},0,-0.2,0.01,1,9,{SR830Twiddle},twiddle.Device,{twiddle.Port},0,1); % sweep offset

sigDACRampVoltage(shieldl.Device,shieldl.Port,-1,numSteps); % make shield negative
% sweep1DMeasSR830({'Shield'},0,-1,0.05,1,9,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep offset

sigDACRampVoltage(offset.Device,offset.Port,1,numSteps); % open offset gate
% sweep1DMeasSR830({'Door'},-1,1,0.1,1,9,{SR830Twiddle},offset.Device,{offset.Port},1,1); % sweep offset

sigDACRampVoltage(door.Device,door.Port,Vopen,numSteps); % open door
% sweep1DMeasSR830({'CCDdoor'},-1,2,0.1,1,9,{SR830Twiddle},door.Device,{door.Port},0,1); % sweep offset
delay(2);

sigDACRampVoltage(offset.Device,offset.Port,Vclose,numSteps); % close offset gate
delay(1);

sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V

% set33622AOutput(Ag2Channel,1, 'ON'); % turn twiddle back on
% set33622AOutput(Ag2Channel,2, 'ON'); % turn compensation back on

sweep1DMeasSR830({'Shield'},-1,0,0.05,1,9,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield