function [ PortObj ] = connectInstrumentPort( Port )
% Connects to the DAC or SIM900, returns the PortObj to be used in 
% communications. Arguments are:
%
% Port: This is the Serial port the Adruino due (Programming Port) uses, 
% can find this in device manager/Adruino program, or the port that the 
% SIM900 is connected to 

PortObj = instrfind('Type', 'serial', 'Port', Port, 'Tag', '');

% Create the Port object if it does not exist
% otherwise use the object that was found.
if isempty(PortObj)
    PortObj = serial(Port);
else
    fclose(PortObj);
    PortObj = PortObj(1);
    
end
fopen(PortObj)
% pause(1);  % need this pause to avoid timeout
% query(PortObj,'*IDN?')
end
