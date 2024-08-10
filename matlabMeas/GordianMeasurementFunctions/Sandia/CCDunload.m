for m = 1:1
    %% Script for decreasing number of electrons in twiddle-sense
    % Run DCPinout before running this script
    numSteps = 500; % sigDACRampVoltage
    numStepsCCD = 500; % sigDACRampVoltage
    numStepsRC = 2; % interleavedRamp
    waitTime = 0.5; % 5 times time constant
    Vopen = 1.5; % holding voltage of ccd
    Vclose = -1.5; % closing voltage of ccdc
    
    interleavedRamp(TM.Device,TM.Port,-1,numStepsRC,waitTime); % make top metal less negative
    
    %% Unload twiddle-sense
    sigDACRampVoltage(twiddle.Device,twiddle.Port,Vclose,numSteps); % close twiddle
    interleavedRamp(shieldl.Device,shieldl.Port,Vclose,numStepsRC,waitTime); % close shield
    interleavedRamp(offset.Device,offset.Port,0.5,numStepsRC,waitTime); % open offset
    interleavedRamp(sense.Device,sense.Port,-0.5,numStepsRC,waitTime); % close sense

    sigDACRampVoltage(door.Device,door.Port,1,numSteps); % open door
    interleavedRamp(offset.Device,offset.Port,Vclose,numStepsRC,waitTime); % close offset
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open ccd1
    sigDACRampVoltage(door.Device,door.Port,-2,numSteps); % close door
    delay(1); % wait for electrons to diffuse across twiddle to door
    fprintf('Twiddle-sense unloaded\n')
    
    %% Move electrons on CCD3 back to ST through CCD
    ccd_units = 63; % number of repeating units in ccd array
    for n = 1:ccd_units
        sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numStepsCCD) % open ccd3
        sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numStepsCCD) % close ccd1
        sigDACRampVoltage(ccd2.Device,ccd2.Port,Vopen,numStepsCCD) % open ccd2
        sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclose,numStepsCCD) % close ccd3
        sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numStepsCCD) % open ccd1
        sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclose,numStepsCCD) % close ccd2
        fprintf([num2str(n),' ']);
    end
    fprintf(['\nElectrons moved ', num2str(ccd_units), ' ccd units\n'])
    
    %% Unload CCD
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vopen,numSteps) % open 3rd door
    sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclose,numSteps) % close ccd1
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vopen,numSteps) % open 2nd door
    sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,Vclose,numSteps) % close 3rd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vopen,numSteps) % open 1st door
    sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,Vclose,numSteps) % close 2nd door
    sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,Vclose,numSteps) % close 1st door
    fprintf('Electrons loaded back onto Sommer-Tanner\n')

    %% Reset twiddle-sense voltages
    sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,numSteps); % set right shield back to -2V
    sigDACRampVoltage(twiddle.Device,twiddle.Port,0,numSteps); % set twiddle back to 0V
    interleavedRamp(shieldl.Device,shieldl.Port,0.1,numStepsRC,waitTime); % set left shield back
    interleavedRamp(sense.Device,sense.Port,0,numStepsRC,waitTime); % set sense back to 0V
    interleavedRamp(offset.Device,offset.Port,-2,numStepsRC,waitTime); % open offset
    fprintf('Twiddle-sense voltages set back\n')

    %% Sweep shield to check for electrons in twiddle
    sweep1DMeasSR830({'Shield'},0.2,-1.5,0.1,3,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
    interleavedRamp(shieldl.Device,shieldl.Port,0.1,numStepsRC,waitTime) % set left shield back
    fprintf(['CCD unload run #',num2str(m),' - END. \n'])
end