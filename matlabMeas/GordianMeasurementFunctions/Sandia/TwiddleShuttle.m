%% Shuttle electron from twiddle-sense onto door and back
numSteps = 2;
waitTime = 0.5; % 5 times time constant
Vopen = 0.6; % holding voltage of ccd
Vclose = -0.6; % closing voltage of ccd

interleavedRamp(TM.Device,TM.Port,-0.67,5,0.1); % make top metal less negative

%% Set potential gradient across twiddle-sense and unload electrons
interleavedRamp(door.Device,door.Port,0.6,numSteps,waitTime); % open door
interleavedRamp(offset.Device,offset.Port,0.3,numSteps,waitTime); % open offset

sigDACRampVoltage(shieldr.Device,shieldr.Port,-3,numSteps); % make right shield negative
sigDACRampVoltage(twiddle.Device,twiddle.Port,-2,numSteps); % make twiddle negative
interleavedRamp(shieldl.Device,shieldl.Port,-1,numSteps,waitTime); % make shield negative
interleavedRamp(sense.Device,sense.Port,-0.3,numSteps,waitTime); % make sense negative
delay(1); % wait for electrons to diffuse across twiddle to door
fprintf('Twiddle-sense unloaded\n')

interleavedRamp(offset.Device,offset.Port,-2,numSteps,waitTime); % close offset

sigDACRampVoltage(shieldr.Device,shieldr.Port,-2,500); % set right shield back to -2V
sigDACRampVoltage(twiddle.Device,twiddle.Port,0,500); % set twiddle back to 0V
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back to 0V
interleavedRamp(sense.Device,sense.Port,0,numSteps,waitTime); % set sense back to 0V
fprintf('Twiddle-sense voltages set back\n')

sweep1DMeasSR830({'Shield'},0.1,-0.4,0.01,1.5,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1); % sweep shield
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back

interleavedRamp(offset.Device,offset.Port,0.6,numSteps,waitTime); % open offset
interleavedRamp(door.Device,door.Port,-0.6,numSteps,waitTime); % close door slowly
interleavedRamp(offset.Device,offset.Port,-2,numSteps,waitTime); % close offset slowly
delay(1);

sweep1DMeasSR830({'Shield'},0.1,-0.4,0.01,1.5,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1);
interleavedRamp(shieldl.Device,shieldl.Port,0.1,numSteps,waitTime); % set left shield back