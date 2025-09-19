%% Script for moving electrons from Sommer-Tanner to 1st twiddle-sense
% Run DCPinout before running this script
numSteps = 10;
numStepsRC = 10;
waitTimeRC = 1100;
Vopen = 3; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

% startShield = 0.4;
% stopShield = -1;
% shieldStep = stopShield-startShield;
Vload = -0.5; % set voltage on d1 and d2

% Open first three doors to CCD - using sigDACRampVoltage function
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vload,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vload,numSteps) % open 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps);% close 1st door
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door

sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
% fprintf('Electrons loaded onto ccd1\n')

%% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open phi3
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close phi3
end

%% Move electrons onto door gate
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1

%% Set sense, guard and twiddle
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % close door right of twiddle
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC) % open sense
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % open guard
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % open twiddle

%% Open offset and door gates and sweep guard for electrons
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open offset
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close offset
delay(1)

MFLISweep1D({'Guard1'},0.5,-0.8,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

% sweep1DMeasATS9416({'Guard1'},102e3,32,0.2,-1,-0.1,0.01,boardHandle,CHANNEL_A,guard1_l.Device,guard1_l.Port,0);
% sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back