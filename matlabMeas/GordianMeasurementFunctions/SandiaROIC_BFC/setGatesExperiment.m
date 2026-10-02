function setGatesExperiment(pinout, varargin)
%setMeasGates Set all bias voltages for measuremend1_event of electrons.
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 2, isnonneg);
p.addParameter('numStepsRC', 2, isnonneg);
p.addParameter('waitTimeRC', 1.1, isnonneg);
p.addParameter('vlow', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % rampDACVolts
numStepsRC = p.Results.numStepsRC; % rampDACVolts
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vlow = p.Results.vlow; % closing voltage of ccd

%% Script to set gate voltages for measurement and initialise ramping parameters
% Run DCPinout before running this script
rampDACVolts(pinout.filament.device,pinout.filament.port,0,numSteps) % set filament backing plate
% delay(1)

%% Set Sommer-Tanner
rampDACVolts(pinout.std.device,pinout.std.port,0,numSteps) % ramp ST-Drive
rampDACVolts(pinout.sts.device,pinout.sts.port,0,numSteps) % ramp ST-Sense
rampDACVolts(pinout.stm.device,pinout.stm.port,0,numSteps) % ramp ST-Middle

%% Set 1st CCD
rampDACVolts(pinout.d1_1.device,pinout.d1_1.port,vlow,numSteps)
rampDACVolts(pinout.d1_2.device,pinout.d1_2.port,vlow,numSteps)
rampDACVolts(pinout.d2.device,pinout.d2.port,vlow,numSteps)
rampDACVolts(pinout.d3.device,pinout.d3.port,vlow,numSteps)

rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_2.device,pinout.phi_h1_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
% delay(1)

rampDACVolts(pinout.bpg.device,pinout.bpg.port,-2,numSteps) % set bond pad guard

%% Set 1st twiddle-sense
rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)
rampDACVolts(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC) % close door
rampDACVolts(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % set left shield back
rampDACVolts(pinout.twiddle1.device,pinout.twiddle1.port,0,numSteps) % set twiddle to 0V
rampDACVolts(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps) % set right shield to -2V
rampDACVolts(pinout.sense1_r.device,pinout.sense1_r.port,vlow,numSteps) % set right sense gate
rampDACVolts(pinout.d6.device,pinout.d6.port,vlow,numSteps)
rampDACVolts(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
% delay(1)

%% Set vertical CCD
rampDACVolts(pinout.phi_v_1.device,pinout.phi_v_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_v_2.device,pinout.phi_v_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_v_3.device,pinout.phi_v_3.port,vlow,numSteps)
% delay(1)

%% Set 2nd twiddle-sense
rampDACVolts(pinout.d7.device,pinout.d7.port,-2,numSteps) % door for compensation of sense 1
rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,0,numSteps)
rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,-2,numSteps)
rampDACVolts(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numSteps)
rampDACVolts(pinout.d8.device,pinout.d8.port,vlow,numSteps)
rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
% delay(1)

%% Set electron trap
rampDACVolts(pinout.d9.device,pinout.d9.port,-2,numSteps)
rampDACVolts(pinout.d10.device,pinout.d10.port,-2,numSteps)
rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)

rampDACVolts(pinout.trap1.device,pinout.trap1.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.trap2.device,pinout.trap2.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.trap3.device,pinout.trap3.port,vlow,numStepsRC,waitTimeRC)
rampDACVolts(pinout.trap4.device,pinout.trap4.port,vlow,numStepsRC,waitTimeRC)

rampDACVolts(pinout.tm.device,pinout.tm.port,-1,numStepsRC,waitTimeRC) % ramp top metal
delay(1)
end