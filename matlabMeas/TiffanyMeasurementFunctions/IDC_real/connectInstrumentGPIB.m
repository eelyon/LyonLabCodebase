function [ GPIBObj ] = connectInstrumentGPIB( boardIndex, GPIBAddress )
% Connects to an instrument via GPIB, returns the GPIBObj to be used in 
% communications. Arguments are:
%
% boardIndex: Integer denoting the board index for the GPIB connection. Use
% NI Max or tmtools to figure this out.
%
% GPIBAddress: integer denoting the GPIB address of instrument. These are 
% typically found on the instrument themselves.

GPIBObj = instrfind('Type', 'gpib', 'BoardIndex', boardIndex, 'PrimaryAddress', GPIBAddress, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(GPIBObj)
    GPIBObj = gpib('NI', boardIndex, GPIBAddress);
else
    fclose(GPIBObj);
    GPIBObj = GPIBObj(1);
end
fopen(GPIBObj)
end
