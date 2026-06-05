function ziSaveSettings(device, filename)
% ZISAVESETTINGS save the settings from the a device to a LabOne settings file
%
% ZISAVESETTINGS(DEVICE, FILENAME)
%
% Save the settings from DEVICE, e.g., 'dev1234', to the LabOne settings file
% FILENAME.
%
% EXAMPLES
%
% Save a settings file in the current directory:
%
%   ziAutoConnect()
%   dev = ziAutoDetect()
%   ziSaveSettings(dev, 'my_settings.xml')
%
% Save a settings file to the default LabOne settings path:
%
%   filename = 'default_ui.xml'
%   default_path = ziGetDefaultSettingsPath()
%   ziSaveSettings(dev, [default_path, filesep, 'default_ui.xml'])
%
% See also ZISAVESETTINGS, ZIGETDEFAULTSETTINGSPATH.

  if nargin < 2
    error('ziSaveSettings: Two input arguments required, a device and filename (both character arrays).');
  end
  if ~ischar(device)
    error('ziSaveSettings: device should be a character array.');
  end
  if ~ischar(filename)
    error('ziSaveSettings: filename should be a character array.');
  end

  [path, filename_noext, ext] = fileparts(filename);
  h = ziDAQ('deviceSettings');

  ziDAQ('set', h, 'device', device);
  ziDAQ('set', h, 'filename', filename_noext);
  if path
    ziDAQ('set', h, 'path', path);
  else
    ziDAQ('set', h, 'path', ['.', filesep]);
  end
  ziDAQ('set', h, 'command', 'save');
  try
    ziDAQ('execute', h);
    tic;
    timeout = 60.0;  % seconds
    while ~ziDAQ('finished', h)
      pause(0.05);
      if toc > timeout
        error('Unable to save device settings after %.2f seconds', timeout)
      end
    end
  catch err
    ziDAQ('clear', h)
    rethrow(err);
  end
  ziDAQ('clear', h)

end
