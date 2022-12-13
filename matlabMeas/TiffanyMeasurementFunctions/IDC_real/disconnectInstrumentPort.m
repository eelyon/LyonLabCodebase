function [ ] = disconnectInstrumentPort( obj1 )
% disconnects from the DAC
%
% Port: This is the Serial port the Adruino due (Programming Port) uses 

%% Disconnect and Clean Up

% Disconnect from instrument object, obj1.
fclose(obj1);
