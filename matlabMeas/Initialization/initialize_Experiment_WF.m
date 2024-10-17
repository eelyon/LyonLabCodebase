%% Script used to initialize an experiment.

port = 1234;

% SR830
SR830_Address = '172.29.117.102';
SR830 = SR830(port,SR830_Address);
% aux port voltages ramp: SR830rampAuxOut(SR830,1,0.2,0.1,0.01)

% 34401
DMM_Address = '172.29.117.104';
Thermometer = TCPIP_Connect(DMM_Address,port);

% DAC
sigDACPort = 'COM4';
DAC = sigDAC(sigDACPort,16,'DAC');
% this GUI only shows the voltage after being updated
DACGUI = sigDACGUI;
% sample code to change voltage: sigDACSetVoltage(DAC,3,0);   sigDACSetChannels(DAC,0)
% ramping code is a bit weird

% SIM900
% connect to SIM900 via RS232
%comPort = 'COM5';
%SIM900 = SIM900(comPort);
% simply call functions in SIM900, e.g. querySIM900Voltage(SIM900,7)
% rampSIM900Voltage(SIM900,port,voltage, pauser, delta)

% If needed run setupENA in folder as well.
% connect ethernet cable behind to VNA




