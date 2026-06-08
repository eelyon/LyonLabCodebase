function [] = electronsRelease(pinout,varargin)
%ELECTRONRELEASE Summary of this function goes here
%   Detailed explanation goes here
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

%% Move electrons out of avalanche trap
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
sigDACRampVoltage(pinout.trap2.device,pinout.trap1.port,-2,numSteps)
sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vlow,numSteps)

for k = 1:22
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
end

sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)

% Reset Sense2 for measurement
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end