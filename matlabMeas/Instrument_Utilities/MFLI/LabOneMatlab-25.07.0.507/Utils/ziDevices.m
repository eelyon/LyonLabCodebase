function devices = ziDevices()
% ZIDEVICES return a cell array of connected Zurich Instruments devices
%
% DEVICES = ZIDEVICES() 
%
% Return a cell array of DEVICES that are currently connected to the server
% using the connection previously initiated by ziDAQ('connect').
%
% See also ZIAUTODETECT, ZIAUTOCONNECT.

% assumes we've already connected to a server via ziDAQ('connect', host, port)
  nodes = lower(ziDAQ('listNodes', '/'));
  dutIndex = strmatch('dev', nodes);
  devices = lower(nodes(dutIndex));
  
end
