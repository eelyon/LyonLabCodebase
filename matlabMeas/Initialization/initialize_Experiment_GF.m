%% Script used to initialize an experiment.
port = 1234; % for the big glass dewar??

%% Thermometer
DMM_Address = '172.29.117.107';
Thermometer = TCPIP_Connect(DMM_Address,port);

%% Keysight VNA E5071
initializeENA;