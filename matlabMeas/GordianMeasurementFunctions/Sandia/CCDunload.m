loop = 1;
for j=1:loop
    %% Script for decreasing number of electrons in twiddle-sense
    % Run DCPinout before running this script
    numSteps = 5;
    numSteps_ccd = 500;
    waitTime = 0.5; % 5 times time constant
    Vopen = 3.5; % holding voltage of ccd
    Vclose = -0.75; % closing voltage of ccdc
    
%     interleavedRamp(TM.Device,TM.Port,-0.7,numSteps,waitTime); % make top metal less negative
    
    %% Set potential gradient across twiddle-sense and unload electrons
    sigDACRampVoltage(ccd1.Device,ccd1.Port,2,500); % open ccd1
    sigDACRampVoltage(door.Device,door.Port,1,500); % open door

    sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,500); % make right shield negative
    sigDACRampVoltage(twiddle.Device,twiddle.Port,-2,5000); % make twiddle negative
    interleavedRamp(shieldl.Device,shieldl.Port,-1,numSteps,waitTime); % make shield negative
    interleavedRamp(offset.Device,offset.Port,0.5,numSteps,waitTime); % open offset
    interleavedRamp(sense.Device,sense.Port,-0.3,numSteps,waitTime); % make sense negative
    delay(1); % wait for electrons to diffuse across twiddle to door
    fprintf('Twiddle-sense unloaded\n')

    interleavedRamp(offset.Device,offset.Port,-2,numSteps,waitTime); % close offset
    sigDACRampVoltage(door.Device,door.Port,Vclose,500); % close door
    
%     sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,500); % set right shield back to -2V
    sigDACRampVoltage(twiddle.Device,twiddle.Port,0,500); % set twiddle back to 0V
    interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back
    interleavedRamp(sense.Device,sense.Port,0,numSteps,waitTime); % set sense back to 0V
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
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,500); % open 3rd door
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,500); % close ccd1
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vopen,500); % open 2nd door
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,500); % close 3rd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vopen,500); % open 1st door
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,500); % close 2nd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,500); % close 1st door
    fprintf('Electrons loaded back onto Sommer-Tanner\n')
    
    %% Sweep shield to check for electrons in twiddle
    sweep1DMeasSR830({'Shield'},0.1,-1,0.1,1,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
    interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back
    fprintf(['CCD unload run #',num2str(j),' - END. \n'])
end