function [] = loadSense1(pinout,vload,varargin)
% Load electrons from Sommer-Tanner to twiddle-sense 1
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vopen', 2, isnonneg);
p.addParameter('vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vopen = p.Results.vopen; % holding voltage of ccd
vclose = p.Results.vclose; % closing voltage of ccd

sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vload,numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vload,numSteps) % open 2nd door
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps);% close 1st door
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vopen,numSteps) % open 3rd door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps) % close 2nd door
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps) % open phi1
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps) % close 3rd door

ccd_units = 64; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vopen,numSteps) % open phi2
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps) % close phi1
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps) % open phi3
    sigDACRampVoltage(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vclose,numSteps) % close phi2
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps) % open phi1
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps) % close phi3
end

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,vclose,numStepsRC,waitTimeRC)

% Reset Sense1
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
end