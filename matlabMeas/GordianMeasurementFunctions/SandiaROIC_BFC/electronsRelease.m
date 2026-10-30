function [] = electronsRelease(pinout,varargin)
%ELECTRONRELEASE Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('vhigh', 2, isnonneg);
p.addParameter('vlow', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % rampDACVolts
vhigh = p.Results.vhigh; % holding voltage of ccd
vlow = p.Results.vlow; % closing voltage of ccd

%% Move electrons out of avalanche trap
rampDACVolts(pinout.d10.device,pinout.d10.port,vhigh,numSteps)
rampDACVolts(pinout.trap1.device,pinout.trap1.port,-2,numSteps)
rampDACVolts(pinout.trap2.device,pinout.trap2.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
rampDACVolts(pinout.d10.device,pinout.d10.port,vlow,numSteps)

for k = 1:22
    rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
    rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
    rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
end

rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
rampDACVolts(pinout.d9.device,pinout.d9.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
rampDACVolts(pinout.d9.device,pinout.d9.port,vlow,numSteps)
rampDACVolts(pinout.d8.device,pinout.d8.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
rampDACVolts(pinout.sense2_r.device,pinout.sense2_r.port,vhigh,numSteps)
rampDACVolts(pinout.d8.device,pinout.d8.port,vlow,numSteps)
rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,vhigh,numSteps)
rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,vhigh,numSteps,pinout.twiddle2.dwell)
rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,vhigh,numSteps,pinout.guard2_l.dwell)
rampDACVolts(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numSteps)
rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,numSteps)

% Reset Sense2 for measurement
rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,-2,numSteps)
rampDACVolts(pinout.d7.device,pinout.d7.port,-2,numSteps,pinout.d7.dwell)
rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,0,numSteps,pinout.guard2_l.dwell)
rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,0,numSteps,pinout.twiddle2.dwell)
rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,0,numSteps)
end