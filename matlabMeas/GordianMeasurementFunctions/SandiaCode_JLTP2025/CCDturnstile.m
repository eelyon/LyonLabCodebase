%% Script for decreasing number of electrons in twiddle-sense
% Run DCPinout before running this script
numSteps = 1000;
numSteps_ccd = 100;
Vopen = 0.6; % holding voltage of ccd
Vclose = 0.6; % closing voltage of ccd
Vdelta = 0.2; % set Vdelta between ccd3 and door

% set33622AOutput(Ag2Channel,1, 'OFF'); % turn twiddle off
% set33622AOutput(Ag2Channel,2, 'OFF'); % turn compensation off

%% Set potential gradient across twiddle-sense and unload electrons
sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numSteps); % open ccd3
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open ccd1
sigDACRampVoltage(door.Device,door.Port,2,numSteps); % open door
sigDACRampVoltage(offset.Device,offset.Port,1,numSteps); % open offset gate

sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make shield negative
sigDACRampVoltage(twiddle.Device,twiddle.Port,-2,numSteps); % make twiddle slightly negative
sigDACRampVoltage(shieldl.Device,shieldl.Port,-1,numSteps); % make shield negative
delay(20); % wait for electrons to diffuse across twiddle to door
fprintf('Twiddle-sense unloaded\n')

sigDACRampVoltage(offset.Device,offset.Port,Vclose,numSteps); % close offset gate

sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % set left shield back to 0V
fprintf('Twiddle-sense voltages set back\n')
fprintf('Electrons unloaded from twiddle-sense\n');

% set33622AOutput(Ag2Channel,1, 'ON'); % turn twiddle back on
% set33622AOutput(Ag2Channel,2, 'ON'); % turn compensation back on

sweep1DMeasSR830({'Shield'},0,-1,0.05,1,9,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % set left shield back to 0V

%% Turnstile using ccd2, ccd3, ccd1, door, and offset
rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vclose,0.1,0.1); % close ccd1 slowly (~1V/sec)
fprintf(['Electrons split: ccd1 ramped to ', num2str(Vclose), 'V\n'])
% open offset
% close door
% close offset
% sweep shield

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for i = 1:ccd_units
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numSteps_ccd); % open ccd3
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps_ccd); % close ccd1
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numSteps_ccd); % open ccd2
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numSteps_ccd); % close ccd3
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps_ccd); % open ccd1
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numSteps_ccd); % close ccd2
    fprintf([num2str(i),' ']);
end
fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units\n']);

%% Unload CCD
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close phi1
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vopen,numSteps); % open 2nd door
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps); % close 3rd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vopen,numSteps); % open 1st door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps); % close 2nd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps); % close 1st door
fprintf('Electrons loaded back onto ST-Sense\n');

%% Sweep shield
sigDACRampVoltage(shieldl.Device,shieldl.Port,-0.5,numSteps); % set left shield back to 0V
sweep1DMeasSR830({'Shield'},-0.5,0.1,0.01,3,1,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % set left shield back to 0V