function [] = shuttleUpSense2(pinout,varargin)
% Shuttle electron from current sense 2 to sense 2 in next channel 1 above
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

sigDACRamp(pinout.d7.device, pinout.d7.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
sigDACRamp(pinout.d7.device, pinout.d7.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vlow, numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vlow, numSteps)
end

sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_v2_3.device, pinout.phi_v2_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vlow, numSteps)

for i = 1:3
    sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v2_3.device, pinout.phi_v2_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device, pinout.phi_v2_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_v2_3.device, pinout.phi_v2_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device, pinout.phi_v2_1.port, vlow, numSteps)
end

sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v2_3.device, pinout.phi_v2_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_v2_1.device, pinout.phi_v2_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vlow, numSteps)
sigDACRampVoltage(pinout.d_v_3.device, pinout.d_v_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v2_1.device, pinout.phi_v2_1.port, vlow, numSteps)
sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d_v_3.device, pinout.d_v_3.port, vlow, numSteps)

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,vlow,numStepsRC,waitTimeRC)

% Reset Sense2 for measurement
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end