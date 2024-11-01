%% Script used to initialize an experiment.

port = 1234;

% SR830
SR830_Address = '172.29.117.102';
SR830 = SR830(port,SR830_Address);
% sweep1DMeasSR830Fast({'SM'},
% first argument only changes the axis names
% aux port voltages ramp: SR830rampAuxOut(SR830,1,0.2,0.1,0.01)

% 34401
% DMM_Address = '172.29.117.104';
% Thermometer = TCPIP_Connect(DMM_Address,1234);

%% Agilent AWGs
deLeonAWG_Address = '172.29.117.133';
Ag2Channel = Agilent33622A(1234,deLeonAWG_Address,1); % two-channel AWG

% DAC
sigDACPort = 'COM4';
DAC = sigDAC(sigDACPort,16,'DAC');
% this GUI only shows the voltage after being updated
DACGUI = sigDACGUI;
% sample code to change voltage: sigDACSetVoltage(DAC,3,0);   sigDACSetChannels(DAC,0)
% sigDACSetChannels(DAC,0)

% SIM900
% connect to SIM900 via RS232
comPort = 'COM5';
SIM900 = SIM900(comPort);
% simply call functions in SIM900, e.g. querySIM900Voltage(SIM900,7)
% rampSIM900Voltage(SIM900,port,voltage, pauser, delta)
 % rampSIM900Voltage(SIM900,[1,3,4,5,7],[0,0,0,0,0],0.01,0.01)

% SDG5122
% connect to SDG5122 via USB-B
% SDGPort = 'USB0::0xF4ED::0xEE3A::SDG050D1150018::INSTR';
% SDG5122 = SDG5122(SDGPort);
% in the case of error using sdg5122, try physically disconnecting and
% connecting back again

% If needed run setupENA in folder as well.
% connect ethernet cable behind to VNA




