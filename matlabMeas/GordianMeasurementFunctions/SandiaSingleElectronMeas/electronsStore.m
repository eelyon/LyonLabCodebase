function [] = electronsStore(pinout,varargin)
% Shuttle electron along 2nd horizontal ccd, store, and run ccd back
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

sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,vhigh,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vhigh,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vlow,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,-2,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vhigh,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRamp(pinout.d8.device,pinout.d8.port,-2,numStepsRC,waitTimeRC) % make more neg. to trap electron
sigDACRamp(pinout.d9.device,pinout.d9.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vlow,numStepsRC,waitTimeRC)

for k = 1:22 % channel narrows after 11
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
end

sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,-2,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,-2,numSteps) % make more neg. to trap electron
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.trap1.device,pinout.trap1.port,-0.5,numSteps)
sigDACRampVoltage(pinout.trap3.device,pinout.trap3.port,-2,numSteps)
sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vlow,numSteps)

% % Now move ccd back to Sense2
% sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
% sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vlow,numSteps)
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
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,vlow,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vlow,numSteps)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,vhigh,numSteps)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,numStepsRC,waitTimeRC)

% Reset Sense2
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end

