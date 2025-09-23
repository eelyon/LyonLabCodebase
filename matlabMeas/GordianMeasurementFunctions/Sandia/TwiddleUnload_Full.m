%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Channels parallel to the 6 used ones are emptied by lifting electrons
% onto top metal through d4 and phi1_1
% Run DCPinout before running this script
numSteps = 5; % sigDACRampVoltage
numStepsRC = 5; % sigDACRamp
waitTimeRC = 1100; % in microseconds
Vopen = 3; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

% startShield = 0.4; % sets start value for shield sweep
% stopShield = -1; % sets stop value for shield sweep
% shieldStep = stopShield-startShield;

%% Unload twiddle-sense
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC) % close twiddle
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC) % close shield
sigDACRamp(d5.Device,d5.Port,0.4,numStepsRC,waitTimeRC) % open door
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,0.8,numSteps) % open d4
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC) % close door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,1.2,numSteps) % open ccd1
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door

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
% sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open door
% sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC) % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTimeRC,delta) % set sense back to 0V
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC) % set twiddle back to 0V
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close d5

%% Sweep shield to check for electrons in twiddle
sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1); % sweep shield
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
delay(1)

% sweep1DMeasATS9416({'Guard1'},102e3,32,0.2,-1,-0.1,0.01,boardHandle,CHANNEL_A,guard1_l.Device,guard1_l.Port,0);
% sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back