%% Script for shuttling electrons from twiddle-sense 2 to twiddle-sense 1
% Purpose is to see if I can retain the number of electrons I start out with
numSteps = 5; % sigDACRampVoltage
numStepsRC = 5; % sigDACRamp
waitTimeRC = 1100; % 5 times time constant
Vopen = 3;
Vclose = -1;
Vload = -0.01;

% Check electron signal in twiddle-sense 2
MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32021',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',5e3,'poll_duration',0.5);
% sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
delay(1)
 
%% Move electrons out of twiddle-sense 2
sigDACRamp(sense2_l.Device,sense2_l.Port,0.4,numStepsRC,waitTimeRC)
sigDACRamp(twiddle2.Device,twiddle2.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard2_l.Device,guard2_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(d7.Device,d7.Port,0.4,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRamp(sense2_l.Device,sense2_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,0.8,numSteps)
sigDACRamp(d7.Device,d7.Port,Vclose,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRampVoltage(d4.Device,d4.Port,1.2,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,1.6,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)

sigDACRamp(twiddle2.Device,twiddle2.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(d7.Device,d7.Port,-2,numStepsRC,waitTimeRC)
delay(1)

% Check if twiddle-sense 2 is truly empty
MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32021',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',5e3,'poll_duration',0.5);
% sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)

% Move electrons through vertical CCD
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)

for a = 1:3
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
end

sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)

% Move electrons to sense 1
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,0.4,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,0.4,numSteps)
sigDACRamp(twiddle1.Device,twiddle1.Port,0.4,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0.4,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,0.4,numStepsRC,waitTimeRC)

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
delay(1)

MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',5e3,'poll_duration',0.5);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)

% Move electrons from sense 1 to Sommer-Tanner
sigDACRamp(d5.Device,d5.Port,0.8,numStepsRC,waitTimeRC) % open door
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,1.2,numSteps) % open d4
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC) % close door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,1.6,numSteps) % open ccd1
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door

% Move electrons through horizontal CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open ccd2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close ccd2
end

% Dump electrons into Sommer-Tanner
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps) % close 1st door
delay(1)

% Move electrons from Sommer-Tanner back to twiddle-sense 2
% sigDACRampVoltage(d1_even.Device,d1_even.Port,Vload,numSteps) % open 1st door
% sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
% sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps);% close 1st door
% sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
% sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door

% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open phi3
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close phi2
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open phi1
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close phi3
end

% Move electrons through sense 1 to twiddle-sense 2
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close phi1
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)

MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',5e3,'poll_duration',0.5);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,0.4,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,0.4,numSteps)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,0.8,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,1.2,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,1.6,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
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
sigDACRamp(d7.Device,d7.Port,Vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRamp(d7.Device,d7.Port,-2,numStepsRC,waitTimeRC)
delay(1)

MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32021',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',5e3,'poll_duration',0.5);
% sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)