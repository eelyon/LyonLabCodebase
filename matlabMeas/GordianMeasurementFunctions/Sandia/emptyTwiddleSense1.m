%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Channels parallel to the 6 used ones are emptied by lifting electrons
% onto top metal through d4 and phi1_1

%% Unload twiddle-sense
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC) % close twiddle
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC) % close shield
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open door
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open d4
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC) % close door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open ccd1
sigDACRampVoltage(d4.Device,d4.Port,Vclose-0.8,numSteps) % close door

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open ccd2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close ccd2
end

%% Unload CCD
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps) % close 1st door

%% Reset twiddle-sense, move stray electrons from d4 back to sense1_l
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open door
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC) % set twiddle back to 0V
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close d5

MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',10,'poll_duration',0.5);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back

% MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',1e3,'poll_duration',0.1);
% sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back