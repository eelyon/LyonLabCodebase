%% Script for decreasing number of electrons in twiddle-sense
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

sigDACRampVoltage(offset.Device,offset.Port,Vclose,numSteps); % close offset
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open ccd1
sigDACRampVoltage(door.Device,door.Port,Vclose,numSteps); % close door
delay(1);

sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V

% set33622AOutput(Ag2Channel,1, 'ON'); % turn twiddle back on
% set33622AOutput(Ag2Channel,2, 'ON'); % turn compensation back on

sweep1DMeasSR830({'Shield'},-1,0,0.05,1,9,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for i = 1:ccd_units
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numSteps); % open ccd3
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close ccd1
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numSteps); % open ccd2
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numSteps); % close ccd3
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open ccd1
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numSteps); % close ccd2
    fprintf([num2str(i),' ']);
end
fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units\n']);

%% Unload CCD
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close phi1
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vload,numSteps); % open 2nd door
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps); % close 3rd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vload,numSteps); % open 1st door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps); % close 2nd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps); % close 1st door
fprintf('Electrons loaded back onto ST-Sense\n');

%% Sweep offset from -1V to 1V and back to check for electrons in twiddle
sweep1DMeasSR830({'Door'},-1,1,0.05,1,3,0.05,{SR830Twiddle},offset.Device,offset.Port,1,1);