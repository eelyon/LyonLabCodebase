%% set up a door pulse using 2 channel AWG
% Ch 1 -> DoorE, Ch 2 -> DoorC

AwgDevice = AwgDoor;

% initialize
set33622AFunctionType(AwgDevice,1,'PULS');
set33622AFunctionType(AwgDevice,2,'PULS');
set33622AOutput(AwgDevice,1,1);
set33622AOutput(AwgDevice,2,1);

set33622ATriggerSource(AwgDevice,1,'BUS')
set33622ATriggerSource(AwgDevice,2,'BUS')

% set door voltage parameters
set33622ADoorVoltageLowAndHigh(AwgDevice,1,-1,0)
set33622ADoorVoltageLowAndHigh(AwgDevice,2,-2.5,-1.5)

% set pulse width
Tau1 = 100e-6;
Tau2 = 75e-6;
set33622APulseWidth(AwgDevice, 1,Tau1);
set33622APulseWidth(AwgDevice, 2,Tau2);

% send trigger
send33622ATriggerBus(AwgDevice)

% %% thin film door pulse
% % set door voltage parameters
% set33220InvertOutput(AwgTwiddle,1);           % invert the output so high is the default state
% 
% set33220VoltageHighAndLow(AwgTwiddle,-3,2)    % TfC gate
% set33220VoltageHighAndLow(AwgComp,-1,0.3)     % DoorEOut gate




