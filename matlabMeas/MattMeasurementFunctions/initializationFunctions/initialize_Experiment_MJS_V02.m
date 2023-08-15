%% Script used to initialize an experiment.

port = 1234;

SR830_Address = '172.29.117.103';
SR830 = SR830(port,SR830_Address);

DMM_Address = '172.29.117.104';
Thermometer = TCPIP_Connect(DMM_Address,port);

AWG_Address = '172.29.117.105';
AWG = Agilent33220A(port,AWG_Address);

SIM928Port = 'COM5';
SIM928Rack = SIM900(SIM928Port);