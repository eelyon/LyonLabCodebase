%% Script for unloading electron in twiddle-sense
% Run DCPinout before running this script
% numSteps = 1000;
% numStepsCCD = 500;
% numStepsRC = 5;
% waitTime = 0.5;
% Vopen = 0.8; % holding voltage of ccd
% Vclose = -0.75; % closing voltage of ccd

%% Set potential gradient across twiddle-sense and unload electrons
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,0.6,numSteps); % open phi1_1
sigDACRampVoltage(d4.Device,d4.Port,0.4,numSteps); % open d4

% sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make right shield negative
% sigDACRampVoltage(twiddle.Device,twiddle.Port,-1.5,numSteps); % make twiddle negative
interleavedRamp(guard1_l.Device,guard1_l.Port,-1,numStepsRC,waitTime); % make shield negative
interleavedRamp(d5.Device,d5.Port,0.2,numStepsRC,waitTime); % open d5
% interleavedRamp(sense.Device,sense.Port,-0.3,numSteps,waitTime); % make sense negative
delay(1); % wait for electrons to diffuse across twiddle to d4
fprintf('Twiddle-sense unloaded\n')

interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime); % close d5
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps); % close d4

% sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
% sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime); % set left shield back
% interleavedRamp(sense.Device,sense.Port,0,numStepsRC,waitTime); % set sense back to 0V
fprintf('Twiddle-sense voltages set back\n')

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for i = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD); % open phi1_3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD); % close phi1_1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numStepsCCD); % open phi1_2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD); % close phi1_3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD); % open phi1_1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numStepsCCD); % close phi1_2
    fprintf([num2str(i),' ']);
end
fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units\n'])

%% Unload CCD
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps); % close phi1_1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps); % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps); % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps); % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps); % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps); % close 1st door
fprintf('Electrons loaded back onto Sommer-Tanner\n')

[avgMag,avgReal,avgImag,stdReal,stdImag] = sweep1DMeasSR830({'Shield'},startShield,stopShield,stopShield-startShield,10,numRepeats,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1);
interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime); % set left shield back