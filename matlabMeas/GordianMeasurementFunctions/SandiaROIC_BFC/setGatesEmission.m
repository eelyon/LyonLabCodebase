function setGatesEmission(pinout, varargin)
%SETEMISSIONGATES Set bias voltages for emitting electrons on device
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1.1, isnonneg);
p.addParameter('vlow', -3, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.addParameter('vbackmetal', 0, @(x) isnumeric(x) && isscalar(x) && (x <= 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % rampDACVolts
numStepsRC = p.Results.numStepsRC; % rampDACVolts
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vlow = p.Results.vlow; % closing voltage of ccd
vbackmetal = p.Results.vbackmetal;

%% Set Sommer-Tanner
rampDACVolts(pinout.tm.device,pinout.tm.port,vlow,numStepsRC,waitTimeRC) % ramp top metal
rampDACVolts(pinout.m2s.device,pinout.m2s.port,-0.5,numSteps) % ramp M2 shield
rampDACVolts(pinout.bpg.device,pinout.bpg.port,vlow,numSteps) % ramp bond pad guard

rampDACVolts(pinout.std.device,pinout.std.port,+2,numSteps) % ramp ST-Drive
rampDACVolts(pinout.sts.device,pinout.sts.port,+2,numSteps) % ramp ST-Sense
rampDACVolts(pinout.stm.device,pinout.stm.port,+2,numSteps) % ramp ST-Middle

%% Set 1st CCD
rampDACVolts(pinout.d1_1.device,pinout.d1_1.port,vlow,numSteps)
rampDACVolts(pinout.d1_2.device,pinout.d1_2.port,vlow,numSteps)
rampDACVolts(pinout.d2.device,pinout.d2.port,vlow,numSteps)
rampDACVolts(pinout.d3.device,pinout.d3.port,vlow,numSteps)

rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)

%% Set 1st twiddle-sense
rampDACVolts(pinout.shield.device,pinout.shield.port,-0.5,numStepsRC,waitTimeRC) % shield underneath twiddle-sense
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)
rampDACVolts(pinout.d5.device,pinout.d5.port,vlow,numStepsRC,waitTimeRC); % compensation
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard1_l.device,pinout.guard1_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle1.device,pinout.twiddle1.port,vlow,numSteps)
rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,vlow,numSteps)
rampDACVolts(pinout.sense1_r.device,pinout.sense1_r.port,vlow,numSteps)
rampDACVolts(pinout.d6.device,pinout.d6.port,vlow,numSteps)

%% Set vertical CCD
rampDACVolts(pinout.phi_v_1.device,pinout.phi_v_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_v_2.device,pinout.phi_v_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_v_3.device,pinout.phi_v_3.port,vlow,numSteps)

%% Set 2nd twiddle-sense
rampDACVolts(pinout.d7.device,pinout.d7.port,vlow,numSteps) % door for compensation of sense 1
rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,vlow,numSteps)
rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,vlow,numSteps)
rampDACVolts(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numSteps)
rampDACVolts(pinout.d8.device,pinout.d8.port,vlow,numSteps)

%% Set electron trap
rampDACVolts(pinout.d9.device,pinout.d9.port,vlow,numSteps)
rampDACVolts(pinout.d10.device,pinout.d10.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)

rampDACVolts(pinout.trap1.device,pinout.trap1.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.trap2.device,pinout.trap2.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.trap3.device,pinout.trap3.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.trap4.device,pinout.trap4.port,vlow,numStepsRC,waitTimeRC)

rampDACVolts(pinout.filament.device,pinout.filament.port,vbackmetal,numSteps) % ramp filament backing plate
end