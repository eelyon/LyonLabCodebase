%% Script for moving electrons from Sommer-Tanner to phi1 before door of 1st twiddle-sense
% Run DCPinout before running this script
% numSteps = 500;
% numStepsCCD = 500; % number of steps in ramp
% numStepsRC = 5;
% waitTime = 0.5;
% Vopen = 0.6; % holding voltage of ccd
% Vclose = -0.6; % closing voltage of ccd
Vload = 0.5; % set voltage on first two doors to control no. of electrons

%% Open first three doors to CCD - using sigDACRampVoltage function
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vload,numSteps); % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vload,numSteps); % open 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps); % close 1st door
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps); % close 2nd door
fprintf('Electrons loaded onto third door\n');

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps); % open phi1
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps); % close 3rd door
fprintf('Electrons loaded onto ccd1\n');

%% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numStepsCCD) % open phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD) % close phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD) % open phi3
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numStepsCCD) % close phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD) % open phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD) % close phi3
    fprintf([num2str(n),' '])
end
fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units into ccd1\n'])

%% Move electrons onto door gate
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
fprintf('Electrons loaded onto door gate\n')

%% Set sense, shield and twiddle
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % close door right of twiddle
% rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,0.1)
interleavedRamp(guard1_l.Device,guard1_l.Port,0.1,numStepsRC,waitTime) % open shield
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % open twiddle
fprintf('Sense, twiddle, and both shield gate voltages set\n')

%% Open offset and door gates and sweep shield for electrons
interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime) % open offset
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime) % close offset
sweep1DMeasATS9416({'Guard'},0.2,-2,0.1,1,1.8e6,boardHandle,CHANNEL_A,guard1_l.Device,guard1_l.Port,1);
interleavedRamp(guard1_l.Device,guard1_l.Port,0.1,numStepsRC,waitTime) % open shield