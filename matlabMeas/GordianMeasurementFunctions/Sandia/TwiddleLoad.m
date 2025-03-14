%% Script for moving electrons from Sommer-Tanner to 1st twiddle-sense
% Run DCPinout before running this script
% numSteps = 20;
% numSteps = 20; % number of steps in ramp
% numStepsRC = 10;
% waitTime = 0.0011;
% Vopen = 1; % holding voltage of ccd
% Vclose = -0.7; % closing voltage of ccd

startShield = 0.2;
stopShield = -1.6;
shieldSteps = stopShield-startShield;
Vload = 0.2; % set voltage on d1 and d2

%% Open first three doors to CCD - using sigDACRampVoltage function
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vload,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vload,numSteps) % open 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps);% close 1st door
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
fprintf('Electrons loaded onto third door\n')

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
fprintf('Electrons loaded onto ccd1\n')

%% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open phi3
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close phi3
    fprintf([num2str(n),' '])
end

%% Move electrons onto door gate
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
fprintf('\nElectrons loaded onto door gate\n')

%% Set sense, guard and twiddle
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % close door right of twiddle
% rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,0.1) % open sense
interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime) % open guard
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % open twiddle
fprintf('Sense, twiddle, and both guard gate voltages set\n')

%% Open offset and door gates and sweep guard for electrons
interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime) % open offset
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime) % close offset
delay(1)

[avg_mag,avg_real,avg_imag,std_real,std_imag] = sweep1DMeasSR830({'Guard'},startShield,stopShield,-0.1,3,5,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1);
interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime) % reset guard