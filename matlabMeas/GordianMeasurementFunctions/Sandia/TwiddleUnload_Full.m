%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Channels parallel to the 6 used ones are emptied by lifting electrons
% onto top metal through d4 and phi1_1
% Run DCPinout before running this script
% numSteps = 20; % sigDACRampVoltage
% numStepsRC = 10; % interleavedRamp
% waitTime = 0.0011; % 5 times time constant
% Vopen = 1; % holding voltage of ccd
% Vclose = -0.7; % closing voltage of ccd

startShield = 0.4; % sets start value for shield sweep
stopShield = -1; % sets stop value for shield sweep
shieldStep = stopShield-startShield;

%% Unload twiddle-sense
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,Vclose,numSteps) % close twiddle
interleavedRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTime) % close shield
interleavedRamp(d5.Device,d5.Port,0.4,numStepsRC,waitTime) % open door
setSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5); delay(2); % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,delta); % close sense
sigDACRampVoltage(d4.Device,d4.Port,0.8,numSteps) % open d4
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime) % close door
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
% fprintf('Electrons loaded back onto Sommer-Tanner\n')

%% Reset twiddle-sense, move stray electrons from d4 back to sense1_l
% interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime) % open door
% sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
setSIM900Voltage(sense1_l.Device,sense1_l.Port,0); delay(2) % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta) % set sense back to 0V
interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime) % set left shield back
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % set twiddle back to 0V
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime) % close d5

%% Sweep shield to check for electrons in twiddle
[avg_Mag,avg_Real,avg_Imag,std_Real,std_Imag] = sweep1DMeasSR830({'Guard'},startShield,stopShield,shieldStep,10,10,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1); % sweep shield
interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime) % set left shield back