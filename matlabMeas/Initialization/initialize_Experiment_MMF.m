%% Script used to initialize an experiment.

port = 1234;

% SR830_Address = '172.29.117.106';
% SR830 = SR830(port,SR830_Address);
% 
% DMM_Address = '172.29.117.107';
% Thermometer = TCPIP_Connect(DMM_Address,port);
% 
% sigDACPort = 'COM4';
% sigDAC = serial_Connect(sigDACPort);
% 
AWG_Address = '172.29.117.108';
AWG = Agilent33220A(port,AWG_Address);