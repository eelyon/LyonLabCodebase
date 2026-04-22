function [] = loadSense1(pinout,vload,varargin)
% Load electrons from Sommer-Tanner to twiddle-sense 1
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vhigh', 2, isnonneg);
p.addParameter('vlow', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vhigh = p.Results.vhigh; % holding voltage of ccd
vlow = p.Results.vlow; % closing voltage of ccd

sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vload,numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vload,numSteps) % open 2nd door
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vlow,numSteps);% close 1st door
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vhigh,numSteps) % open 3rd door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vlow,numSteps) % close 2nd door
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps) % open phi1
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vlow,numSteps) % close 3rd door

% ccdShuttleForward(pinout.phi_h1_1.device,'A',64*3);

ccd_units = 64; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vhigh,numSteps) % open phi2
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps) % close phi1
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps) % open phi3
    sigDACRampVoltage(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vlow,numSteps) % close phi2
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps) % open phi1
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps) % close phi3
end

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,vlow,numStepsRC,waitTimeRC)

% Reset Sense1
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
end