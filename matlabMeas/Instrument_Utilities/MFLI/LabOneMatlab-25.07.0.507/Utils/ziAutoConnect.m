function ziAutoConnect(defaultPort, APILevel)
% ZIAUTOCONNECT create a connection to a Zurich Instruments server for HF2 and UHF instruments
%
% NOTE ZIAUTOCONNECT does not support MFLI devices.
%
% ZIAUTOCONNECT(DEFAULTPORT)
%
% Try to connect to a Zurich Instruments server with an available HF2 or UHFLI
% device. First check if a device is found by connecting to a server on
% DEFAULTPORT, if so create and return a connection to that ziServer. If no
% devices are found on that server, check if a device is found on the
% secondary port, if so create and return a connection to that server. By
% default, a connection is returned to an HF2 server. A runtime error is
% thrown if no devices are found.
%
% See also ZIAUTODETECT, ZIDEVICES.

  if ~exist('defaultPort', 'var')
    defaultPort = 8005;
    secondaryPort = 8004;
    trySecondaryPort = 1; % true
  elseif (defaultPort == 8004) || (defaultPort == 8005)
    trySecondaryPort = 0; % false
    secondaryPort = NaN;
  else
    error('ziAutoConnect(): input argument defaultPort (%d) must be either 8004 (UHF) or 8005 (HF2).', defaultPort);
  end

  if ~exist('APILevel', 'var')
    % Note: level 1 used by default for both UHF and HF2, backwards compatibility
    % not maintained.
    APILevel = 1;
  end

  clear ziDAQ;
  try
    ziDAQ('connect', 'localhost', defaultPort, APILevel);
    devs = ziDevices();
  catch exception
    % Ignore exception
    devs = {};
  end
  if ~isempty(devs) > 0
    % we have a server running and a device, we're done
    fprintf('ziAutoConnect(): connected to a server on port %d using API Level %d.\n', defaultPort, APILevel)
    return
  end

  if trySecondaryPort == 0
    error('ziAutoConnect():  failed to find a running server or failed to find a device connected to the server on port %d. Please ensure that the correct Zurich Instruments server is running for your device and that your device is connected to the server (try connecting first via the User Interface).', defaultPort);
  end

  clear ziDAQ;
  try
    ziDAQ('connect', 'localhost', secondaryPort, APILevel);
    devs = ziDevices();
  catch exception
    % Ignore exception
    devs = {};
  end
  if ~isempty(devs) > 0
    % we have a server running and a device, we're done
    fprintf('ziAutoConnect(): connected to a server on port %d using API Level %d.\n', secondaryPort, APILevel)
    return
  end
  % error checking, keep it simple
  error('ziAutoConnect(): failed to find a running server or failed to find a device connected to the server. Please ensure that the correct Zurich Instruments server is running for your device and that your device is connected to the server (try connecting via the User Interface).');

end
