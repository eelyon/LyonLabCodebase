%% Script used to initialize an experiment.

% 34401
DMM_Address = '172.29.117.104';
Thermometer = TCPIP_Connect(DMM_Address,1234);

% Define DAC Channels
Filament_backing = [15];
Top_metal = [6];
Gates_no_st = [1,2,3,4,5,7,8,9,10,11]; % gates other than sommer tanner l,m,r and top metal and backing
Gates_st = [12,16,14];

% SR830
SR830_Address = '172.29.117.102';
SR830 = SR830(1234,SR830_Address);
% sweep1DMeasSR830Fast({'SM'}, 'TM' 'TWW' 'Door'
% first argument only changes the axis names
% aux port voltages ramp: SR830rampAuxOut(SR830,1,0.2,0.1,0.01)

%% Agilent 33220A Compensate AWG
AWG_Address = '172.29.29.6';
AWG = Agilent33220A(1234,AWG_Address,1); % one-channel AWG
% compensateParasitics(SR830,AWG,AWG,-180,180,5,0.3,0.35,0.010,0)

% DAC
sigDACPort = 'COM4';
DAC = sigDAC(sigDACPort,16,'DAC');
% this GUI only shows the voltage after being updated
DACGUI = sigDACGUI;
% sample code to change voltage: sigDACSetVoltage(DAC,3,0);   sigDACSetChannels(DAC,0)
% sigDACSetChannels(DAC,0)







% 33220A 2 chan ethernet
% Address_33622 = '172.29.117.140';
% AWG = Agilent33622A(1234,Address_33622,1);

% SIM900
% connect to SIM900 via RS232
% comPort = 'COM5';
% SIM900 = SIM900(comPort);
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




