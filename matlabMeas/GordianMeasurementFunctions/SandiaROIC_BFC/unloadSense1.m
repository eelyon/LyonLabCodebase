function [] = unloadSense1(pinout,varargin)
% Move electrons from sense 1 back to Sommer-Tanner
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vhigh', 2, isnonneg);
p.addParameter('vlow', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % rampDACVolts
numStepsRC = p.Results.numStepsRC; % rampDACVolts
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vhigh = p.Results.vhigh; % holding voltage of ccd
vlow = p.Results.vlow; % closing voltage of ccd

% rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,-3,numStepsRC,waitTimeRC)
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,vhigh,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle1.device,pinout.twiddle1.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard1_l.device,pinout.guard1_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC) % open door
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps) % open d4
rampDACVolts(pinout.d5.device,pinout.d5.port,vlow,numStepsRC,waitTimeRC) % close door
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps) % open ccd1
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps) % close door

% ccdShuttleBackward(pinout.phi_h1_1.device,'A',64*3);

% Move electrons through horizontal CCD
ccd_units = 64; % number of repeating units in ccd array
for n = 1:ccd_units
    rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps) % open ccd3
    rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps) % close ccd1
    rampDACVolts(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vhigh,numSteps) % open ccd2
    rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps) % close ccd3
    rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps) % open ccd1
    rampDACVolts(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vlow,numSteps) % close ccd2
end

% Dump electrons into Sommer-Tanner
rampDACVolts(pinout.d3.device,pinout.d3.port,vhigh,numSteps) % open 3rd door
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps) % close ccd1
rampDACVolts(pinout.d2.device,pinout.d2.port,vhigh,numSteps) % open 2nd door
rampDACVolts(pinout.d3.device,pinout.d3.port,vlow,numSteps) % close 3rd door
rampDACVolts(pinout.d1_1.device,pinout.d1_1.port,vhigh,numSteps) % open 1st door
rampDACVolts(pinout.d2.device,pinout.d2.port,vlow,numSteps) % close 2nd door
% rampDACVolts(pinout.sts.device,pinout.sts.port,+1,numSteps)
rampDACVolts(pinout.d1_1.device,pinout.d1_1.port,vlow,numSteps) % close 1st door
% rampDACVolts(pinout.sts.device,pinout.sts.port,0,numSteps)

% Reset Sense1
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
rampDACVolts(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)

% Move electrons back from cut off channels parallel to sense1
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps) % open ccd1
rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps) % close door
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
rampDACVolts(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC) % open door
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps) % close door
rampDACVolts(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
end