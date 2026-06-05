function [] = shuttleElectrons(pinout, varargin)
%SHUTTLEELECTRONS Script for shuttling electrons
%   Detailed explanation goes here

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 5, isnonneg);
p.addParameter('numStepsRC', 5, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vload', 0, @isnumeric)
p.addParameter('vopen', 3, isnonneg);
p.addParameter('vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vload = p.Results.vload;
vopen = p.Results.vopen; % holding voltage of ccd
vclose = p.Results.vclose; % closing voltage of ccd

%% Move electrons from Sommer-Tanner to twiddle-sense 1
% loadTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, vload, vopen, vclose)
% delay(1)
% 
% MFLISweep1D({'Guard1'},0.2,-1.2,0.05,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',0.01,'demod_rate',100,'poll_duration',0.5);
% % sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electrons from twiddle-sense 1 to twiddle-sense 2
% shuttleTwiddle1Twiddle2(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% delay(1)
% 
% MFLISweep1D({'Guard2'},0.2,-1,0.05,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.5);
% % sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.device,{guard2_l.port},0,1);
% sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
% 
% % Check if twiddle-sense 1 is truly empty
% MFLISweep1D({'Guard1'},0.2,-1,0.05,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.5);
% % sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electrons from twiddle-sense 2 to twiddle-sense 1
% shuttleTwiddle2Twiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% delay(1)
% 
% MFLISweep1D({'Guard1'},0.2,-1,0.05,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.5);
% % sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard
% 
% % Check if twiddle-sense 2 is truly empty
% MFLISweep1D({'Guard2'},0.2,-1,0.05,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.5);
% % sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.device,{guard2_l.port},0,1);
% sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)

%% Move electrons from twiddle-sense 1 to Sommer-Tanner
emptyTwiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
% sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
% sigDACRampVoltage(pinout.d5.device,pinout.d5.port,vopen,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
% sigDACRampVoltage(pinout.d5.device,pinout.d5.port,vclose,numSteps)
delay(1)

% Check electron signal in twiddle-sense 1
MFLISweep1D({'Guard1'},0.2,-1.2,0.1,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.5);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.device,{guard2_l.port},0,1);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
end

function loadTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, vload, vopen, vclose)
% Load electrons from Sommer-Tanner to twiddle-sense 1
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vload,numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vload,numSteps) % open 2nd door
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps);% close 1st door
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vopen,numSteps) % open 3rd door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps) % close 2nd door
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps) % open phi1
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps) % close 3rd door

% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vopen,numSteps) % open phi2
    sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps) % close phi1
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps) % open phi3
    sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vclose,numSteps) % close phi2
    sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps) % open phi1
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps) % close phi3
end

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
end

function shuttleTwiddle1Twiddle2(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi_Vdown_2.device,pinout.phi_Vdown_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
%     emptyCCD1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
%     fprintf([num2str(j), ' '])
end

sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vclose,numSteps)

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)

sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end

function shuttleTwiddle2Twiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vclose,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)

sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)

sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device,pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vclose,numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
%     emptyCCD1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
%     fprintf([num2str(j), ' '])
end

sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device,pinout.phi_Vdown_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vopen,numStepsRC,waitTimeRC)

sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
end

function emptyTwiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRamp(pinout.d5.device,pinout.d5.port,vopen,numStepsRC,waitTimeRC) % open door
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps) % open d4
sigDACRamp(pinout.d5.device,pinout.d5.port,vclose,numStepsRC,waitTimeRC) % close door
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps) % open ccd1
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps) % close door

% Move electrons through horizontal CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps) % open ccd3
    sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps) % close ccd1
    sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vopen,numSteps) % open ccd2
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps) % close ccd3
    sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps) % open ccd1
    sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vclose,numSteps) % close ccd2
end

% Dump electrons into Sommer-Tanner
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vopen,numSteps) % open 3rd door
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps) % close ccd1
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vopen,numSteps) % open 2nd door
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps) % close 3rd door
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vopen,numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps) % close 2nd door
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps) % close 1st door
end