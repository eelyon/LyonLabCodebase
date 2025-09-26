function [] = shuttleElectrons(pinout, varargin)
%SHUTTLEELECTRONS Script for shuttling electrons
%   Detailed explanation goes here

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 10, isnonneg);
p.addParameter('numStepsRC', 10, isnonneg);
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
loadTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, vload, vopen, vclose)
delay(1)

MFLISweep1D({'Guard1'},0.4,-0.8,0.1,'dev32021',guard1_l.device,guard1_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
sigDACRamp(guard1_l.device,guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electrons from twiddle-sense 1 to twiddle-sense 2
shuttleTwiddle1Twiddle2(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

MFLISweep1D({'Guard2'},0.4,-0.8,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',1e3,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)

%% Move electrons from twiddle-sense 2 to twiddle-sense 1
shuttleTwiddle2Twiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

MFLISweep1D({'Guard1'},0.4,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

% Check if twiddle-sense 2 is truly empty
MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',1e3,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)

%% Move electrons from twiddle-sense 1 to Sommer-Tanner
emptyTwiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

% Check electron signal in twiddle-sense 1
MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.device,guard1_l.port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.device,{guard2_l.port},0,1);
sigDACRamp(guard1_l.device,guard1_l.port,0,numStepsRC,waitTimeRC)
end

function loadTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, vload, vopen, vclose)
% Load electrons from Sommer-Tanner to twiddle-sense 1
sigDACRampVoltage(d1_even.device,d1_even.port,vload,numSteps) % open 1st door
sigDACRampVoltage(d2.device,d2.port,vload,numSteps) % open 2nd door
sigDACRampVoltage(d1_even.device,d1_even.port,vclose,numSteps);% close 1st door
sigDACRampVoltage(d3.device,d3.port,vopen,numSteps) % open 3rd door
sigDACRampVoltage(d2.device,d2.port,vclose,numSteps) % close 2nd door
sigDACRampVoltage(phi1_1.device,phi1_1.port,vopen,numSteps) % open phi1
sigDACRampVoltage(d3.device,d3.port,vclose,numSteps) % close 3rd door

% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_2.device,phi1_2.port,vopen,numSteps) % open phi2
    sigDACRampVoltage(phi1_1.device,phi1_1.port,vclose,numSteps) % close phi1
    sigDACRampVoltage(phi1_3.device,phi1_3.port,vopen,numSteps) % open phi3
    sigDACRampVoltage(phi1_2.device,phi1_2.port,vclose,numSteps) % close phi2
    sigDACRampVoltage(phi1_1.device,phi1_1.port,vopen,numSteps) % open phi1
    sigDACRampVoltage(phi1_3.device,phi1_3.port,vclose,numSteps) % close phi3
end

sigDACRampVoltage(d4.device,d4.port,vopen,numSteps)
sigDACRampVoltage(phi1_1.device,phi1_1.port,vclose,numSteps)
sigDACRamp(d5.device,d5.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.device,d4.port,vclose,numSteps)
sigDACRamp(sense1_l.device,sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.device,guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.device,twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(d5.device,d5.port,-2,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard1_r.device,guard1_r.port,-2,numSteps)
end

function shuttleTwiddle1Twiddle2(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,vopen,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,vopen,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d6.Device,d6.Port,vopen,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)

sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
    emptyCCD1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
    fprintf([num2str(j), ' '])
end

sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,vclose,numSteps)

sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)
sigDACRamp(d7.Device,d7.Port,vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRamp(sense2_l.Device,sense2_l.Port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(guard2_l.Device,guard2_l.Port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(twiddle2.Device,twiddle2.Port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(d7.Device,d7.Port,-2,numStepsRC,waitTimeRC)

sigDACRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(twiddle2.Device,twiddle2.Port,0,numStepsRC,waitTimeRC)
end

function shuttleTwiddle2Twiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRamp(d7.Device,d7.Port,vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRamp(twiddle2.Device,twiddle2.Port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard2_l.Device,guard2_l.Port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(sense2_l.Device,sense2_l.Port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRamp(d7.Device,d7.Port,vclose,numStepsRC,waitTimeRC) % door for compensation of sense 1
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)

sigDACRamp(twiddle2.Device,twiddle2.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(d7.Device,d7.Port,-2,numStepsRC,waitTimeRC)

sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,vclose,numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
    emptyCCD1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
    fprintf([num2str(j), ' '])
end

sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,vclose,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,vopen,numSteps)
sigDACRamp(twiddle1.Device,twiddle1.Port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,vopen,numStepsRC,waitTimeRC)

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
end

function emptyTwiddle1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRamp(d5.device,d5.port,vopen,numStepsRC,waitTimeRC) % open door
sigDACRamp(sense1_l.device,sense1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.device,d4.port,vopen,numSteps) % open d4
sigDACRamp(d5.device,d5.port,vclose,numStepsRC,waitTimeRC) % close door
sigDACRampVoltage(phi1_1.device,phi1_1.port,vopen,numSteps) % open ccd1
sigDACRampVoltage(d4.device,d4.port,vclose,numSteps) % close door

% Move electrons through horizontal CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_3.device,phi1_3.port,vopen,numSteps) % open ccd3
    sigDACRampVoltage(phi1_1.device,phi1_1.port,vclose,numSteps) % close ccd1
    sigDACRampVoltage(phi1_2.device,phi1_2.port,vopen,numSteps) % open ccd2
    sigDACRampVoltage(phi1_3.device,phi1_3.port,vclose,numSteps) % close ccd3
    sigDACRampVoltage(phi1_1.device,phi1_1.port,vopen,numSteps) % open ccd1
    sigDACRampVoltage(phi1_2.device,phi1_2.port,vclose,numSteps) % close ccd2
end

% Dump electrons into Sommer-Tanner
sigDACRampVoltage(d3.device,d3.port,vopen,numSteps) % open 3rd door
sigDACRampVoltage(phi1_1.device,phi1_1.port,vclose,numSteps) % close ccd1
sigDACRampVoltage(d2.device,d2.port,vopen,numSteps) % open 2nd door
sigDACRampVoltage(d3.device,d3.port,vclose,numSteps) % close 3rd door
sigDACRampVoltage(d1_even.device,d1_even.port,vopen,numSteps) % open 1st door
sigDACRampVoltage(d2.device,d2.port,vclose,numSteps) % close 2nd door
sigDACRampVoltage(d1_even.device,d1_even.port,vclose,numSteps) % close 1st door
end