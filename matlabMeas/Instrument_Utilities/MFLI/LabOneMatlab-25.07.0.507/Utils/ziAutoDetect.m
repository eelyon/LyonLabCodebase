function device = ziAutoDetect()
% ZIAUTODETECT return the ID of a connected device (if only one device is connected)
%
% DEVICE = ZIAUTODETECT()
%
% See also ZIAUTOCONNECT, ZIDEVICES.

% assumes we've already connected to a server via ziDAQ('connect')
  devices = ziDevices();
  if length(devices) > 1
    % NOTE strjoin() unavailable in Matlab2009.
    devices_str = '';
    for dev=devices
      devices_str = [devices_str, ', ', dev{1}];
    end
    error('Multiple devices found (%s). ziAutoDetect() only supports a single device configuration.', devices_str(3:end));
  elseif isempty(devices)
    error('ziAutoDetect(): No device found. Please ensure that the device is connected to the host and the device is turned on.');
  end
% found only one device -> selection valid.
  device = devices{1};
  fprintf('ziAutoDetect(): Detected device %s.\n', device)
end
