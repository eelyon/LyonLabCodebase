%% set up a door pulse
% AwgTwiddle -> DoorE, AwgComp -> DoorC
% connect sync of twd to ext trig of comp

% initialize
setAgilent33220APresetConfig(AwgTwiddle,'Door');
setAgilent33220APresetConfig(AwgComp,'Door');
set33220TriggerSource(AwgComp,'EXT');

% set door voltage parameters
set33220VoltageHighAndLow(AwgTwiddle,-1,0)
set33220VoltageHighAndLow(AwgComp,-2.5,-1.5)

% set pulse width
Tau1 = 100e-6;
Tau2 = 75e-6;
SetAgilentDoorWidth(AwgTwiddle,AwgComp,Tau1,Tau2)

% send trigger
send33220Trigger(AwgTwiddle)

%% thin film door pulse
% set door voltage parameters
set33220InvertOutput(AwgTwiddle,1);           % invert the output so high is the default state

set33220VoltageHighAndLow(AwgTwiddle,-3,2)    % TfC gate
set33220VoltageHighAndLow(AwgComp,-1,0.3)     % DoorEOut gate


