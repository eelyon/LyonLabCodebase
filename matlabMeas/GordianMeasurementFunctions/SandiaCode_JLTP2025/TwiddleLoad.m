%% Script for moving electrons from Sommer-Tanner to phi1 before door of 1st twiddle-sense
% Run DCPinout before running this script
% startShield = 0.2;
% stopShield = -1;
% shieldSteps = stopShield-startShield;

numSteps = 500;
numStepsCCD = 500; % number of steps in ramp
numStepsRC = 5;
waitTime = 0.5;

% Vload = 0; % set voltage on first two doors to control no. of electrons
Vopen = 0.8; % holding voltage of ccd
Vclose = -0.7; % closing voltage of ccd

%% Open first three doors to CCD - using sigDACRampVoltage function
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vload,numSteps); % open 1st door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vload,numSteps); % open 2nd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps); % close 1st door
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps); % close 2nd door
fprintf('Electrons loaded onto third door\n');

sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open phi1
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps); % close 3rd door
fprintf('Electrons loaded onto ccd1\n');

%% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numStepsCCD) % open phi2
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numStepsCCD) % close phi1
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numStepsCCD) % open phi3
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numStepsCCD) % close phi2
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numStepsCCD) % open phi1
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numStepsCCD) % close phi3
    fprintf([num2str(n),' '])
end

%% Move electrons onto door gate
sigDACRampVoltage(door.Device,door.Port,Vopen,numSteps) % open door
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps) % close phi1
fprintf('\nElectrons loaded onto door gate\n')

%% Set sense, shield and twiddle
sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps) % close door right of twiddle
interleavedRamp(sense.Device,sense.Port,0,numStepsRC,waitTime) % open sense
interleavedRamp(shieldl.Device,shieldl.Port,startShield,numStepsRC,waitTime) % open shield
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps) % open twiddle
fprintf('Sense, twiddle, and both shield gate voltages set\n')

%% Open offset and door gates and sweep shield for electrons
interleavedRamp(offset.Device,offset.Port,Vopen,numStepsRC,waitTime) % open offset
sigDACRampVoltage(door.Device,door.Port,Vclose,numSteps) % close door
interleavedRamp(offset.Device,offset.Port,-2,numStepsRC,waitTime) % close offset
delay(1);

[avg_mag,avg_real,avg_imag,std_real,std_imag] = sweep1DMeasSR830Fast({'Shield'},0.15,-0.15,-0.05,10,1,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1);
interleavedRamp(shieldl.Device,shieldl.Port,startShield,numStepsRC,waitTime) % open shield