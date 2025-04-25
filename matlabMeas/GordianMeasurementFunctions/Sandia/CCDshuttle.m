%% Shuttle electron from twiddle-sense onto d4 and back
% numSteps = 20;
% waitTime = 0.0011; % 5 times time constant
% Vopen = 1; % holding voltage of ccd
% Vclose = -0.7; % closing voltage of ccd
% delta = 0.1;

% interleavedRamp(TM.Device,TM.Port,-0.67,5,0.1); % make top metal less negative

%% Set potential gradient across twiddle-sense and unload electrons
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,0.6,500) % open phi1_1
interleavedRamp(d4.Device,d4.Port,0.6,numSteps,waitTime) % open d4
interleavedRamp(d5.Device,d5.Port,0.3,numSteps,waitTime) % open d5

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-3,numSteps) % make right shield negative
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,-2,numSteps) % make twiddle1 negative
interleavedRamp(guard1_l.Device,guard1_l.Port,-1,numSteps,waitTime) % make shield negative
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,delta)
delay(1) % wait for electrons to diffuse across twiddle1 to d4
fprintf('Twiddle-sense unloaded\n')

interleavedRamp(d5.Device,d5.Port,-2,numSteps,waitTime) % close d5

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,500) % set right shield back to -2V
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,500) % set twiddle1 back to 0V
interleavedRamp(guard1_l.Device,guard1_l.Port,0.1,numSteps,waitTime) % set left shield back to 0V
rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta) % set sense1_l back to 0V
fprintf('Twiddle-sense voltages set back\n')

sweep1DMeasSR830({'Shield'},0.1,-0.6,0.02,1,10,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1); % sweep shield
interleavedRamp(guard1_l.Device,guard1_l.Port,0.1,numSteps,waitTime) % set left shield back

interleavedRamp(d5.Device,d5.Port,0.6,numSteps,waitTime) % open d5
interleavedRamp(d4.Device,d4.Port,-0.6,numSteps,waitTime) % close d4 slowly
interleavedRamp(d5.Device,d5.Port,-2,numSteps,waitTime) % close d5 slowly
delay(1)

sweep1DMeasSR830({'Shield'},0.1,-0.6,0.02,1,10,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1);
interleavedRamp(guard1_l.Device,guard1_l.Port,0.1,numSteps,waitTime) % set left shield back