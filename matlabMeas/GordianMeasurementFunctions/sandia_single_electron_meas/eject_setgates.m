function eject_setgates(pinout, varargin)
%SETGATESEJECT Remove all electrons from device
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 10, isnonneg);
p.addParameter('numStepsRC', 10, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vclose', -2, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vclose = p.Results.vclose; % closing voltage of ccd

%% Set backing plate and top metal positive then sweep ST middle gate
setSIM900Voltage(pinout.filament.device,pinout.filament.port,4) % ramp filament backing plate
delay(1)
sigDACRamp(pinout.tm.device,pinout.tm.port,1,numStepsRC,waitTimeRC) % make top metal positive
delay(1)

%% Set ST gates negative
sigDACRampVoltage(pinout.std.device,pinout.std.port,vclose,numSteps) % Sommer-Tanner drive
sigDACRampVoltage(pinout.sts.device,pinout.sts.port,vclose,numSteps) % Sommer-Tanner sense
sigDACRampVoltage(pinout.stm.device,pinout.stm.port,vclose,numSteps) % Sommer-Tanner middle gate
sigDACRampVoltage(pinout.bpg.device,pinout.bpg.port,vclose,numSteps) % bond pad guard

%% Set CCD gates negative
sigDACRampVoltage(pinout.d1_odd.device,pinout.d1_odd.port,vclose,numSteps)
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps)
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)

%% Set 1st twiddle-sense negative
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC) % rampSIM900Voltage(sense1_l.device,sense1_l.port,-0.5,waitTimeRC,delta);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
sigDACRamp(pinout.shield.device,pinout.shield.port,vclose,numStepsRC,waitTimeRC)
delay(1)

%% Set 2nd twiddle-sense negative
sigDACRampVoltage(pinout.d7.device,pinout.d7.port,vclose,numSteps) % door for compensation of sense 1
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC); delay(1) % rampSIM900Voltage(sense2_l.device,sense2_l.port,-0.5,waitTimeRC,delta);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vclose,numSteps)
delay(1)

%% Set vertical CCD
sigDACRampVoltage(pinout.phi_Vdown_1.device,pinout.phi_Vdown_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device,pinout.phi_Vdown_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device,pinout.phi_Vdown_3.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi_Vup_1.device,pinout.phi_Vup_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vup_2.device,pinout.phi_Vup_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vup_3.device,pinout.phi_Vup_3.port,vclose,numSteps)

sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_Vup_3.device,pinout.d_Vup_3.port,vclose,numSteps)

%% Set electron trap
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)

sigDACRamp(pinout.trap1_2.device,pinout.trap1_2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap1_1.device,pinout.trap1_1.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap2_2.device,pinout.trap2_2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap2_1.device,pinout.trap2_1.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap5.device,pinout.trap5.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap6.device,pinout.trap6.port,vclose,numStepsRC,waitTimeRC)
delay(1)

sigDACRamp(pinout.tm.device,pinout.tm.port,-1,numStepsRC,waitTimeRC) % make top metal negative
fprintf('Electrons are ejected.\n')
end