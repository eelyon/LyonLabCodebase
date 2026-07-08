function [obj1] = TCPIP_VISA_Connect(IP_Address)
%% Function creates a TCPIP connection and returns the object which
%% holds the connection information.

% Params: 
%   IP_Address: string, IP Address of target instrument.

%% Instrument Connection
% Find a VISA-TCPIP object.
obj1 = instrfind('Type', 'visa-tcpip', 'RsrcName', IP_Address, 'Tag', '');

% Create the visa-tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('NI', ['TCPIP0::' ,num2str(IP_Address), '::inst0::INSTR']);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

end