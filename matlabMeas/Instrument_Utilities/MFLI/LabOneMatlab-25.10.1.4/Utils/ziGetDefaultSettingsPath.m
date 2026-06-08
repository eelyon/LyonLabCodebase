function settings_path = ziGetDefaultSettingsPath()
% ZIGETDEFAULTSETTINGSPATH return the default path for LabOne settings files.
%
% ZIGETDEFAULTSETTINGSPATH()
%
% Return a string containing the default path for LabOne settings files as
% defined in the ziCore Module ziDeviceSettings.
%
% See also ZISAVESETTINGS, ZILOADSETTINGS

  h = ziDAQ('deviceSettings');
  settings_path = ziDAQ('get', h, 'path');
  settings_path = char(settings_path.path{1});
  ziDAQ('clear', h);

end
