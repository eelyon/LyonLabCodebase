%% Instrument Connection
clear fieldFox % Clear current fieldFox object

% Find a VISA-TCPIP object.
fieldFox = instrfind('Type', 'visa-tcpip', 'RsrcName', 'TCPIP0::172.29.117.100::inst0::INSTR', 'Tag', '');

% Create the VISA-TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(fieldFox)
    fieldFox = visa('NI', 'TCPIP0::172.29.117.100::inst0::INSTR');
else
    fclose(fieldFox);
    fieldFox = fieldFox(1);
end

set(fieldFox, 'InputBufferSize', 80000);
set(fieldFox, 'OutputBufferSize', 80000);
set(fieldFox,'ByteOrder', 'littleEndian');

% Connect to instrument object, obj1.
fopen(fieldFox);
myId = fscanf(fieldFox,'%c');
%% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = query(fieldFox, '*IDN?')
