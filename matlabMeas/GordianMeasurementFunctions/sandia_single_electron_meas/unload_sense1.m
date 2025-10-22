function [] = unload_sense1(pinout,varargin)
% Move electrons from sense 1 back to Sommer-Tanner
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 5, isnonneg);
p.addParameter('numStepsRC', 5, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('Vopen', 1, isnonneg);
p.addParameter('Vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vopen = p.Results.Vopen; % holding voltage of ccd
vclose = p.Results.Vclose; % closing voltage of ccd

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

% Reset sense 1
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
end

