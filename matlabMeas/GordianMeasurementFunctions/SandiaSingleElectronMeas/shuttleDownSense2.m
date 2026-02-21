function [] = shuttleDownSense2(pinout,varargin)
% Shuttle electron from current sense 2 to sense 2 in next channel 1 above
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

sigDACRamp(pinout.d7.device, pinout.d7.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
sigDACRamp(pinout.d7.device, pinout.d7.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)

sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vclose,numSteps) % E are on d_v_2
% sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vopen,numSteps)
% sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)

for j = 1:3
    sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
end

sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vclose,numSteps)

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,vclose,numStepsRC,waitTimeRC)

% Reset sense2 for measurement
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end