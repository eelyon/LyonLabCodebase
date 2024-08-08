%% Load any electrons left in CCD back into Sommer-Tanner
loop = 5;
for j=1:loop
    % Run DCPinout before running this script
    numSteps = 2;
    numSteps_ccd = 100;
    waitTime = 0.5;
    Vopen = 0.6; % holding voltage of ccd
    Vclose = -0.6; % closing voltage of ccd

    interleavedRamp(door.Device,door.Port,Vopen,numSteps,waitTime); % open door
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,500); % open ccd1
    interleavedRamp(door.Device,door.Port,Vclose,numSteps,waitTime); % close door

    %% Move electrons on CCD3 back to ST through CCD
    ccd_units = 63; % number of repeating units in ccd array
    for i = 1:ccd_units
        sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numSteps_ccd); % open ccd3
        sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps_ccd); % close ccd1
        sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numSteps_ccd); % open ccd2
        sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numSteps_ccd); % close ccd3
        sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps_ccd); % open ccd1
        sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numSteps_ccd); % close ccd2
%         fprintf([num2str(i),' ']);
    end
    fprintf(['\n-> Electrons moved ', num2str(ccd_units), ' ccd units\n'])
    
    %% Unload CCD
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,500); % open 3rd door
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,500); % close ccd1
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vopen,500); % open 2nd door
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,500); % close 3rd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vopen,500); % open 1st door
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,500); % close 2nd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,500); % close 1st door
    fprintf('-> Electrons loaded back onto Sommer-Tanner\n')
end