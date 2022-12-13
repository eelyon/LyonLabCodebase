function [ ] = disconnectInstrumentTCPIP( obj1, remoteHost )

% remoteHost: IP address of the GPIB-Ethernet controller

%% Disconnect and Clean Up

% Disconnect from instrument object, obj1.
fclose(obj1);

%% Instrument Configuration and Control
IPaddress = sprintf('TCPIP-%d', remoteHost);

% Configure instrument object, obj1.
set(obj1, 'Name', IPaddress);
set(obj1, 'RemoteHost', remoteHost);