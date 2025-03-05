%% Move electrons out of 1st twiddle sense back to Sommer-Tanner
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
interleavedRamp(guard1_r.Device,guard1_r.Port,Vopen,numStepsRC,waitTime)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,Vopen,numSteps)
interleavedRamp(guard1_l.Device,guard1_l.Port,Vopen,numStepsRC,waitTime)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,Vclose,numSteps)
sigDACRampVoltage(guard1_l.Device,guard1_l.Port,Vclose,numSteps)
interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime)
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,delta)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
interleavedRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD)
sigDACRampVoltage(d4.Device,d4.Port,-2,numSteps) % Set d4 to -2V so that electrons in channels parallel cannot escape

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numStepsCCD) % open ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD) % close ccd1
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD) % open ccd2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numStepsCCD) % close ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numStepsCCD) % open ccd1
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numStepsCCD) % close ccd2
%     fprintf([num2str(n),' ']);
end

%% Unload CCD
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps) % close 1st door
fprintf('Electrons loaded back onto Sommer-Tanner\n')