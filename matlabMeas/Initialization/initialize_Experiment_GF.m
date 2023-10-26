% Script used to initialize an experiment.

port = 1234;

DMM_Address = '172.29.117.107'; % This is the number of the ethernet card (??) at the back of the intstrument

% Thermometer
Thermometer = TCPIP_Connect(DMM_Address,port);