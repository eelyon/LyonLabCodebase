%% Script for moving electrons from Sommer-Tanner to phi1 before door of 1st twiddle-sense
% Run DCPinout before running this script
numSteps = 1000; % number of steps in ramp
Vload = 0; % set voltage on first two doors to control no. of electrons
Vopen = 2; % holding voltage of ccd
Vclose = -2; % closing voltage of ccd
delayTime = 2; % set delay before next step

%% Open first three doors to CCD - using sigDACRampVoltage function
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vload,numSteps); % open 1st door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vload,numSteps); % open 2nd door
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps); % close 1st door
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps); % close 2nd door
fprintf('Electrons loaded onto third door\n');
delay(delayTime);

sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open phi1
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps); % close 3rd door
fprintf('Electrons loaded onto ccd1\n');
delay(delayTime);

%% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for i = 1:ccd_units
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numSteps); % open phi2
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close phi1
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numSteps); % open phi3
    sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numSteps); % close phi2
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open phi1
    sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numSteps); % close phi3
    fprintf([num2str(i),' ']);
end
fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units into ccd1\n']);
delay(delayTime);

%% Move electrons onto door gate
sigDACRampVoltage(door.Device,door.Port,Vopen,numSteps); % open door
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close phi1
fprintf('Electrons loaded onto door gate\n');
delay(delayTime);

%% Set sense, shield and twiddle
sigDACRampVoltage(sense.Device,sense.Port,0,numSteps); % open sense
sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % open shield
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % open twiddle
sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % close door right of twiddle
fprintf('Sense, twiddle, and both shield gate voltages set\n');
delay(delayTime);

%% Sweep offset and door gates
sigDACRampVoltage(offset.Device,offset.Port,Vopen,numSteps);
sigDACRampVoltage(door.Device,door.Port,Vclose,numSteps);
sigDACRampVoltage(offset.Device,offset.Port,Vclose,numSteps);
sweep1DMeasSR830({'Shield'},0,-0.5,0.02,3,1,{SR830Twiddle},shieldl.Device,{shieldl.Port},1,1); % sweep shield