function [] = shuttleSense2Sense1(pinout,varargin)
%SHUTTLE_SENSE2SENSE1 Shuttle electrons from sense 2 to sense 1
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

sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)

sigDACRamp(pinout.d7.device,pinout.d8.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)

sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vclose,numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vopen,numStepsRC,waitTimeRC)

sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
end

