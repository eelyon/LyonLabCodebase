function [] = shuttleStore(pinout,varargin)
% Shuttle electron along 2nd horizontal ccd, store, and run ccd back
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('Vopen', 2, isnonneg);
p.addParameter('Vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vopen = p.Results.Vopen; % holding voltage of ccd
vclose = p.Results.Vclose; % closing voltage of ccd

sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRamp(pinout.d8.device,pinout.d8.port,-2,numStepsRC,waitTimeRC) % make more neg. to trap electron
sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)

for k = 1:22 % channel narrows after 11
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,-2,numSteps) % make more neg. to trap electron
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.trap1.device,pinout.trap1.port,-2,numSteps)
sigDACRampVoltage(pinout.trap3.device,pinout.trap3.port,-2,numSteps)
sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-1,numSteps)
sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)

% Now move ccd back to ts2 and measure but leave d10 closed
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)

for k = 1:22
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
end

