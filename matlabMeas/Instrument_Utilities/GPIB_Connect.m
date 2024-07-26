
function [obj1] = GPIB_Connect(boardIndex,Address)

%% Function creates a GPIB connection and returns the object which
%% holds the connection information.

% Params: 
%   IP_Address: string, IP Address of target instrument.

%% Instrument Connection

% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', boardIndex, 'PrimaryAddress', Address, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', boardIndex, Address);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);
end


