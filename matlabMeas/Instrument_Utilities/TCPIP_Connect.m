
function [obj1] = TCPIP_Connect(IP_Address,port)

%% Function creates a TCPIP connection and returns the object which
%% holds the connection information.

% Params: 
%   IP_Address: string, IP Address of target instrument.
%   port: integer, desired port in which to make the connection

%% Instrument Connection

% Find a tcpip object.
obj1 = instrfind('Type', 'tcpip', 'RemoteHost', IP_Address, 'RemotePort', port, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = tcpip(IP_Address, 1234);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

end

