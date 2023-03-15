function [obj1] = USB_Connect(USB)

%% Function creates a USB connection and returns the object which
%% holds the connection information.

% Params: 
%   USB: USB address string

%% Instrument Connection

% Find a USB object.
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', USB, 'Tag', '');

% Create the usb object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('NI', USB);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

end
