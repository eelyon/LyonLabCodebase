function [] = shuttleNextSense2(pinout,varargin)
% Shuttle electron from current sense 2 to sense 2 in next channel 1 above
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

sigDACRamp(pinout.d7.device, pinout.d7.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRamp(pinout.d7.device, pinout.d7.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, vclose, numSteps)

for j = 1:76
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
end

sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)

for i = 1:3
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vclose, numSteps)
end

sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_3.device, pinout.d_Vup_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_3.device, pinout.d_Vup_3.port, vclose, numSteps)

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
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)

sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end

