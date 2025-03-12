%% Load any electrons left in CCD back into Sommer-Tanner
% Leaves door (here offset) to sense closed
% Run DCPinout before running this script
% numSteps = 20;
% waitTime = 0.0011;
% Vopen = 1; % holding voltage of ccd
% Vclose = -0.7; % closing voltage of ccd

interleavedRamp(d4.Device,d4.Port,0.8,numSteps,waitTime); % open d4
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps); % open phi1_1
interleavedRamp(d4.Device,d4.Port,Vclose,numSteps,waitTime); % close d4

% Open doors between ST and CCD to allow electrons to leave CCD
sigDACRampVoltage(d1_even.Device,d1_even.Port,0,numSteps)
sigDACRampVoltage(d2.Device,d2.Port,0,numSteps)
sigDACRampVoltage(d3.Device,d3.Port,0,numSteps)

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for i = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps); % open phi1_3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps); % close phi1_1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps); % open phi1_2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps); % close phi1_3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps); % open phi1_1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps); % close phi1_2
    % fprintf([num2str(i),' ']);
end
fprintf(['Electrons moved ', num2str(ccd_units), ' ccd units\n'])

%% Unload CCD
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps); % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps); % close phi1_1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps); % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps); % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps); % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps); % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps); % close 1st door
fprintf('Electrons loaded back onto Sommer-Tanner\n')