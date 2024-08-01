loop = 1;
for j=1:loop
    %% Script for decreasing number of electrons in twiddle-sense
    % Run DCPinout before running this script
    numSteps = 5000;
    numSteps_ccd = 500;
    Vopen = 2; % holding voltage of ccd
    Vclose = -2; % closing voltage of ccd
    
    % set33622AOutput(Ag2Channel,1, 'OFF'); % turn twiddle off
    % set33622AOutput(Ag2Channel,2, 'OFF'); % turn compensation off
    
    %% Set potential gradient across twiddle-sense and unload electrons
    sigDACRampVoltage(ccd1.Device,ccd1.Port,3,numSteps); % open ccd1
    sigDACRampVoltage(door.Device,door.Port,2,numSteps); % open door
    sigDACRampVoltage(offset.Device,offset.Port,1,numSteps); % open offset

    sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make right shield negative
    sigDACRampVoltage(twiddle.Device,twiddle.Port,-2,numSteps); % make twiddle negative
    sigDACRampVoltage(shieldl.Device,shieldl.Port,-2,numSteps); % make shield negative
    delay(20); % wait for electrons to diffuse across twiddle to door
    fprintf('Twiddle-sense unloaded\n')

    sigDACRampVoltage(offset.Device,offset.Port,Vclose,numSteps); % close offset
    sigDACRampVoltage(door.Device,door.Port,Vclose,numSteps); % close door
    
    % set33622AOutput(Ag2Channel,1, 'ON'); % turn twiddle back on
    % set33622AOutput(Ag2Channel,2, 'ON'); % turn compensation back on
    
    sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
    sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
    sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % set left shield back to 0V
    fprintf('Twiddle-sense voltages set back\n')
    
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
    fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units\n'])
    
    %% Unload CCD
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps); % open 3rd door
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps); % close phi1
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vopen,numSteps); % open 2nd door
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps); % close 3rd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vopen,numSteps); % open 1st door
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps); % close 2nd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps); % close 1st door
    fprintf('Electrons loaded back onto ST-Sense\n')
    
    %% Sweep offset from -1V to 1V and back to check for electrons in twiddle
    sigDACRampVoltage(shieldl.Device,shieldl.Port,-0.5,numSteps); % set left shield back to 0V
    sweep1DMeasSR830({'Shield'},-0.5,0.1,0.01,3,1,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
%     sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % set left shield back to 0V
    fprintf(['CCD unload run #',num2str(j),' - END. \n'])
end