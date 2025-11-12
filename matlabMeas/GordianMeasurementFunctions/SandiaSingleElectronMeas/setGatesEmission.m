function setGatesEmission(pinout, varargin)
%SETEMISSIONGATES Set bias voltages for emitting electrons on device
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 10, isnonneg);
p.addParameter('numStepsRC', 10, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vclose', -6, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vclose = p.Results.vclose; % closing voltage of ccd

%% Set Sommer-Tanner
sigDACRamp(pinout.tm.device,pinout.tm.port,-3.4,numStepsRC,waitTimeRC) % ramp top metal
sigDACRampVoltage(pinout.m2s.device,pinout.m2s.port,-0.5,numSteps) % ramp M2 shield
sigDACRampVoltage(pinout.bpg.device,pinout.bpg.port,vclose,numSteps) % ramp bond pad guard

sigDACRampVoltage(pinout.std.device,pinout.std.port,+2,numSteps) % ramp ST-Drive
sigDACRampVoltage(pinout.sts.device,pinout.sts.port,+2,numSteps) % ramp ST-Sense
sigDACRampVoltage(pinout.stm.device,pinout.stm.port,+2,numSteps) % ramp ST-Middle

%% Set 1st CCD
sigDACRampVoltage(pinout.d1_odd.device,pinout.d1_odd.port,vclose,numSteps)
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps)
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)

%% Set 1st twiddle-sense
sigDACRamp(pinout.shield.device,pinout.shield.port,-0.5,numStepsRC,waitTimeRC) % shield underneath twiddle-sense
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,vclose,numStepsRC,waitTimeRC); % compensation
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)

%% Set vertical CCD
sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vclose,numSteps)

sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vclose,numSteps)

%% Set 2nd twiddle-sense
sigDACRampVoltage(pinout.d7.device,pinout.d7.port,vclose,numSteps) % door for compensation of sense 1
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numSteps)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vclose,numSteps)

%% Set electron trap
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)

sigDACRamp(pinout.trap1.device,pinout.trap1.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap2.device,pinout.trap2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap3.device,pinout.trap3.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap4.device,pinout.trap4.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap5.device,pinout.trap5.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap6.device,pinout.trap6.port,vclose,numStepsRC,waitTimeRC)

setSIM900Voltage(pinout.filament.device,pinout.filament.port,-3.5) % ramp filament backing plate
end

