%% Script for unloading electron in twiddle-sense
% Run DCPinout before running this script
numSteps = 500; % sigDACRampVoltage
numStepsCCD = 500; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.5; % interleavedRamp
Vopen = 3; % holding voltage of ccd
Vclose = -0.75; % closing voltage of ccd

%% Set potential gradient across twiddle-sense and unload electrons
sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numStepsCCD); % open ccd2
sigDACRampVoltage(ccd1.Device,ccd1.Port,2,numSteps); % open ccd1
sigDACRampVoltage(door.Device,door.Port,1,numSteps); % open door

% sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make right shield negative
sigDACRampVoltage(twiddle.Device,twiddle.Port,-1.5,numSteps); % make twiddle negative
interleavedRamp(shieldl.Device,shieldl.Port,-1,numStepsRC,waitTime); % make shield negative
interleavedRamp(offset.Device,offset.Port,0.5,numStepsRC,waitTime); % open offset
% interleavedRamp(sense.Device,sense.Port,-0.3,numSteps,waitTime); % make sense negative
delay(1); % wait for electrons to diffuse across twiddle to door
fprintf('Twiddle-sense unloaded\n')

%% Push electrons onto top metal
interleavedRamp(offset.Device,offset.Port,-2,numSteps,waitTime); % close offset
sigDACRampVoltage(door.Device,door.Port,-2,numSteps); % close door
sigDACRampVoltage(ccd1.Device,ccd1.Port,-1.5,numSteps*10); % open ccd1

%% Reset twiddle-sense
% sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numStepsRC,waitTime); % set left shield back
interleavedRamp(sense.Device,sense.Port,0,numStepsRC,waitTime); % set sense back to 0V
fprintf('Twiddle-sense voltages set back\n')

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for i = 1:ccd_units
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numStepsCCD); % open ccd3
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numStepsCCD); % close ccd1
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numStepsCCD); % open ccd2
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numStepsCCD); % close ccd3
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numStepsCCD); % open ccd1
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numStepsCCD); % close ccd2
    fprintf([num2str(i),' ']);
end
fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units\n'])

%% Unload CCD
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close ccd1
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vopen,numSteps); % open 2nd door
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps); % close 3rd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vopen,numSteps); % open 1st door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps); % close 2nd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps); % close 1st door
fprintf('Electrons loaded back onto Sommer-Tanner\n')

[avgMag,avgReal,avgImag,stdReal,stdImag] = sweep1DMeasSR830({'Shield'},0.1,-0.7,0.02,3,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1);
interleavedRamp(shieldl.Device,shieldl.Port,startShield,numStepsRC,waitTime); % set left shield back