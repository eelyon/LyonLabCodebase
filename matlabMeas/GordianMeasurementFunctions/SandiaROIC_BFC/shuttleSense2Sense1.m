function [] = shuttleSense2Sense1(pinout,varargin)
%SHUTTLE_SENSE2SENSE1 Shuttle electrons from sense 2 to sense 1
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vhigh', 2, isnonneg);
p.addParameter('vlow', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % rampDACVolts
numStepsRC = p.Results.numStepsRC; % rampDACVolts
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vhigh = p.Results.vhigh; % holding voltage of ccd
vlow = p.Results.vlow; % closing voltage of ccd

% rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,-3,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.d7.device,pinout.d7.port,vhigh,numStepsRC,waitTimeRC)
rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
rampDACVolts(pinout.d7.device,pinout.d7.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
rampDACVolts(pinout.d_v_2.device,pinout.d_v_2.port,vhigh,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)

rampDACVolts(pinout.d_v_1.device,pinout.d_v_1.port,vhigh,numSteps)
rampDACVolts(pinout.d_v_2.device,pinout.d_v_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vhigh,numSteps)
rampDACVolts(pinout.d_v_1.device,pinout.d_v_1.port,vlow,numSteps)

for j = 1:75
    rampDACVolts(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vlow,numSteps)
    rampDACVolts(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vlow,numSteps)
    rampDACVolts(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vlow,numSteps)
end

rampDACVolts(pinout.phi_v1_2.device, pinout.phi_v1_2.port,vhigh,numSteps)
rampDACVolts(pinout.phi_v1_3.device, pinout.phi_v1_3.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
rampDACVolts(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vlow,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
rampDACVolts(pinout.d6.device,pinout.d6.port,vhigh,numSteps)
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)
rampDACVolts(pinout.sense1_r.device,pinout.sense1_r.port,vhigh,numSteps)
rampDACVolts(pinout.d6.device,pinout.d6.port,vlow,numSteps)
rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,vhigh,numSteps)
rampDACVolts(pinout.twiddle1.device,pinout.twiddle1.port,vhigh,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard1_l.device,pinout.guard1_l.port,vhigh,numStepsRC,waitTimeRC)
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,vhigh,numStepsRC,waitTimeRC)
rampDACVolts(pinout.sense1_r.device,pinout.sense1_r.port,vlow,numSteps)
rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,vlow,numSteps)

% Reset sense1 for measurement
rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
rampDACVolts(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)

% Reset sense2 for measurement
rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,-2,numSteps)
rampDACVolts(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end