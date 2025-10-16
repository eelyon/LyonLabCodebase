function setGatesEject(pinout, varargin)
%SETGATESEJECT Script for removing all electrons from device
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 10, isnonneg);
p.addParameter('numStepsRC', 10, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('Vclose', -2, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
Vclose = p.Results.Vclose; % closing voltage of ccd

%% Set backing plate and top metal positive then sweep ST middle gate
setSIM900Voltage(pinout.filament.device,pinout.filament.port,4) % ramp filament backing plate
delay(1)
sigDACRamp(pinout.tm.device,pinout.tm.port,1,numStepsRC,waitTimeRC) % make top metal positive
delay(1)

%% Set ST gates negative
sigDACRampVoltage(pinout.std.device,pinout.std.port,Vclose,numSteps) % Sommer-Tanner drive
sigDACRampVoltage(pinout.sts.device,pinout.sts.port,Vclose,numSteps) % Sommer-Tanner sense
sigDACRampVoltage(pinout.stm.device,pinout.stm.port,Vclose,numSteps) % Sommer-Tanner middle gate
sigDACRampVoltage(pinout.bpg.device,pinout.bpg.port,Vclose,numSteps) % bond pad guard

%% Set CCD gates negative
sigDACRampVoltage(pinout.d1_odd.device,pinout.d1_odd.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,Vclose,numSteps)

sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,Vclose,numSteps)

%% Set 1st twiddle-sense negative
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,Vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,Vclose,numStepsRC,waitTimeRC) % rampSIM900Voltage(sense1_l.device,sense1_l.port,-0.5,waitTimeRC,delta);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,Vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,Vclose,numSteps)
sigDACRamp(pinout.shield.device,pinout.shield.port,Vclose,numStepsRC,waitTimeRC)
delay(1)

%% Set 2nd twiddle-sense negative
sigDACRampVoltage(pinout.d7.device,pinout.d7.port,Vclose,numSteps) % door for compensation of sense 1
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,Vclose,numStepsRC,waitTimeRC); delay(1) % rampSIM900Voltage(sense2_l.device,sense2_l.port,-0.5,waitTimeRC,delta);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,Vclose,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,Vclose,numSteps)
delay(1)

%% Set vertical CCD
sigDACRampVoltage(pinout.phi_Vdown_1.device,pinout.phi_Vdown_1.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device,pinout.phi_Vdown_2.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device,pinout.phi_Vdown_3.port,Vclose,numSteps)

sigDACRampVoltage(pinout.phi_Vup_1.device,pinout.phi_Vup_1.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vup_2.device,pinout.phi_Vup_2.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi_Vup_3.device,pinout.phi_Vup_3.port,Vclose,numSteps)

sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,Vclose,numSteps)
sigDACRampVoltage(pinout.d_Vup_3.device,pinout.d_Vup_3.port,Vclose,numSteps)

%% Set electron trap
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,Vclose,numSteps)
sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,Vclose,numSteps)

sigDACRamp(pinout.trap1_2.device,pinout.trap1_2.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap1_1.device,pinout.trap1_1.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap2_2.device,pinout.trap2_2.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap2_1.device,pinout.trap2_1.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap5.device,pinout.trap5.port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.trap6.device,pinout.trap6.port,Vclose,numStepsRC,waitTimeRC)
delay(1)

sigDACRamp(pinout.tm.device,pinout.tm.port,-1,numStepsRC,waitTimeRC) % make top metal negative
fprintf('Electrons are ejected.\n')
end

