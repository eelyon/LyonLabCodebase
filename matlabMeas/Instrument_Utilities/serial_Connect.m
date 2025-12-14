function [obj1] = serial_Connect(COMPort)
% Creates a serial connection for an instrument.
% Inputs: 
%           COMPort: character string of the form COM# which denotes the
%           COM port to connect to.
%% Instrument Connection

% Find a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', COMPort, 'Tag', '');
% obj1 = serialportfind(COMPort,9600,Tag=""); % Default baudrate is 9600

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial(COMPort);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);
end