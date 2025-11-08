function experimentSetGates(pinout, varargin)
%setMeasGates Set all bias voltages for measurement of electrons.
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 10, isnonneg);
p.addParameter('numStepsRC', 10, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vclose = p.Results.vclose; % closing voltage of ccd

%% Script to set gate voltages for measurement and initialise ramping parameters
% Run DCPinout before running this script
setSIM900Voltage(pinout.filament.device,pinout.filament.port,-0.5) % set back filament backing plate
delay(1)

%% Set Sommer-Tanner
sigDACRampVoltage(pinout.std.device,pinout.std.port,0,numSteps) % ramp ST-Drive
sigDACRampVoltage(pinout.sts.device,pinout.sts.port,0,numSteps) % ramp ST-Sense
sigDACRampVoltage(pinout.stm.device,pinout.stm.port,0,numSteps) % ramp ST-Middle

%% Set 1st CCD
sigDACRampVoltage(pinout.d1_odd.device,pinout.d1_odd.port,vclose,numSteps)
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps)
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
delay(1)

sigDACRampVoltage(pinout.bpg.device,pinout.bpg.port,-2,numSteps) % set bond pad guard

%% Set 1st twiddle-sense
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC) % close door
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % set left shield back
sigDACRampVoltage(pinout.twiddle1.device,pinout.twiddle1.port,0,numSteps) % set twiddle to 0V
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps) % set right shield to -2V
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps) % set right sense gate
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
delay(1)

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
delay(1)

%% Set 2nd twiddle-sense
sigDACRampVoltage(pinout.d7.device,pinout.d7.port,-2,numSteps) % door for compensation of sense 1
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.twiddle2.device,pinout.twiddle2.port,0,numSteps)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,-2,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
delay(1)

%% Set electron trap
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,-2,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)

sigDACRamp(pinout.trap1.device,pinout.trap1.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap2.device,pinout.trap2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap3.device,pinout.trap3.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap4.device,pinout.trap4.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap5.device,pinout.trap5.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap6.device,pinout.trap6.port,vclose,numStepsRC,waitTimeRC)
delay(1)

sigDACRamp(pinout.tm.device,pinout.tm.port,-1.2,numStepsRC,waitTimeRC) % ramp top metal
end