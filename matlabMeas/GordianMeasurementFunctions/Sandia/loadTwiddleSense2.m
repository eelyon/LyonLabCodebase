numSteps = 50; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.002; % 5 times time constant
Vopen = 0.8;
Vclose = -0.8;

%% Open first three doors to CCD - using sigDACRampVoltage function
% sigDACRampVoltage(d1_even.Device,d1_even.Port,Vload,numSteps) % open 1st door
% sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
% sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps);% close 1st door
% sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
% sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
% sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
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
%     fprintf([num2str(n),' '])
end

%% Move electrons onto door gate
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
interleavedRamp(sense1_l.Device,sense1_l.Port,0.2,numStepsRC,waitTime)
interleavedRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTime)
interleavedRamp(guard1_l.Device,guard1_l.Port,0.2,numStepsRC,waitTime)
interleavedRamp(twiddle1.Device,twiddle1.Port,0.2,numStepsRC,waitTime)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,0.2,numSteps)
interleavedRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,0.2,numSteps)
interleavedRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTime)
interleavedRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,0.4,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,0.6,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,0.8,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % Electrons on phi1_3

% Open gates to let electrons onto vertical CCD
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
% sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
% sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)

for a = 1:3
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
end

sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)

sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
interleavedRamp(d7.Device,d7.Port,Vopen,numStepsRC,waitTime)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps); delay(1)
interleavedRamp(d7.Device,d7.Port,Vclose,numStepsRC,waitTime)
delay(1);
sweep1DMeasSR830({'Guard'},0.2,-2,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},1,1);