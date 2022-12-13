function [ TCPIPObj ] = connectInstrumentTCPIP( remoteHost )
% Connects to an instrument via TCPIP, returns the TCPIPObj to be used in 
% communications. Arguments are:
%
% remoteHost: IP address of the GPIB-Ethernet controller
%
% remotePort: Port of the GPIB-Ethernet controller, will always be 1234

%% Instrument Connection

% Find a tcpip object.
TCPIPObj = instrfind('Type', 'tcpip', 'RemoteHost', remoteHost, 'RemotePort', 1234, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(TCPIPObj)
    TCPIPObj = tcpip(remoteHost, 1234);
else
    fclose(TCPIPObj);
    TCPIPObj = TCPIPObj(1);
end

% % Communicating with instrument object, obj1.
fopen(TCPIPObj)
% pause(1);  % need this pause to avoid timeout
% query(TCPIPObj,'*IDN?')
end
