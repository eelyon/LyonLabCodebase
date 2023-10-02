% Script used to initialize an experiment.

port = 1234;

DMM_Address = '172.29.117.107';

% Thermometer
Thermometer = TCPIP_Connect(DMM_Address,port);