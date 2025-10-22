function [device, props] =  ziCreateAPISession(device_serial, maximum_supported_apilevel, varargin)
% ZICREATEAPISESSION Create an API session for the specified device
%
% [DEVICE, PROPS] = ZICREATEAPISESSION(DEVICE_SERIAL, MAXIMUM_SUPPORTED_APILEVEL)
%
%   Create an API session to DEVICE_SERIAL's Data Server using the
%   MAXIMUM_SUPPORTED_APILEVEL and return:
%
%     DEVICE (str): The device's ID, this is the string that specifies the
%       device's xnode branch in the data server's node tree.
%
%     PROPS (struct): The device's discovery properties as returned by ziDAQ's
%       'discoveryGet' method.
%
%   Inputs:
%
%   DEVICE_SERIAL (str): A string specifying the device serial number. For
%     example, 'uhf-dev2123' or 'dev2123'.
%
%   MAXIMUM_SUPPORTED_APILEVEL (int): The maximum API Level that is supported
%     by the Matlab code where the returned API session will be used. The
%     maximum API Level you may use is defined by the device class. HF2 only
%     supports API Level 1 and other devices support API Level 5. You should
%     try to use the maximum level possible to enable extended API features.
%
%   Optional Varargin Inputs:
%
%   REQUIRED_DEVTYPE (str): The required device type, e.g., 'HF2LI' or
%     'MFLI'. This is given by the value of the device node
%     '/devX/features/devtype' or the 'devicetype' discovery property. Raise
%     an error if the DEVICE's devtype does not match the `REQUIRED_DEVTYPE`.
%
%   REQUIRED_OPTIONS (cell array of str/regexp): The required device option
%     set. This should be in the same format as returned by the 'options'
%     property as returned by 'discoveryGet', e.g., {'PID', 'DIG'}, although
%     the entry may be a regular expression, e.g., {'MFK|MF|MD', 'DIG'} if the
%     required option functionality has a different name on different device
%     classes. Raise an error if the DEVICE's option set does contain the
%     `REQUIRED_OPTIONS`.
%
%   REQUIRED_ERR_MSG (str) : An additional error message to print if either
%     the DEVICE specified by the DEVICE_SERIAL is not the REQUIRED_DEVTYPE or
%     does not have the REQUIRED_OPTIONS.
%
% See also EXAMPLE_CONNECT, EXAMPLE_SWTRIGGER_EDGE.

% Check the ziDAQ MEX (DLL) and Utility functions can be found in Matlab's path.
if ~(exist('ziDAQ') == 3) && ~(exist('ziDevices', 'file') == 2)
    fprintf('Failed to either find the ziDAQ mex file or ziDevices() utility.\n')
    fprintf('Please configure your path using the ziDAQ function ziAddPath().\n')
    fprintf('This can be found in the API subfolder of your LabOne installation.\n');
    fprintf('On Windows this is typically:\n');
    fprintf('C:\\Program Files\\Zurich Instruments\\LabOne\\API\\MATLAB2012\\\n');
    return
end

% Define and parse `varargin` input arguments.
p = inputParser;
p.addParamValue('required_devtype', '.*', @ischar);
p.addParamValue('required_options', '', @iscellstr);
p.addParamValue('required_err_msg', '', @ischar);
p.parse(varargin{:});
required_devtype = p.Results.required_devtype;
required_options = p.Results.required_options;
required_err_msg = p.Results.required_err_msg;

clear ziDAQ;

% Determine the device identifier from it's serial/id
device = lower(ziDAQ('discoveryFind', device_serial));

% Get the device's default connectivity properties.
props = ziDAQ('discoveryGet', device);

if ~props.discoverable
  error(['The specified device `' device_serial '` is not discoverable from the API. ', ...
         'Please ensure the device is powered-on and visible using the LabOne User Interface ', ...
         'or ziControl.'])
end

if isempty(regexp(props.devicetype, required_devtype))
  error(['Required device type not satisfied. Device type `' props.devicetype , ...
         '` does not match the required device type: `' required_devtype, '`. ' required_err_msg])
end

if ~isempty(required_options)
  assert(iscellstr(required_options), ['The required_options argument must be a cell ', ...
                      'array of strings, each entry specifying a device option.'])
  missing_options = regex_option_diff(required_options, props.options);
  if ~isempty(missing_options)
    installed_options_str = ''; % Note: strjoin() unavailable in Matlab 2009.
    for option=props.options
      installed_options_str = [installed_options_str, ' ', option{1}];
    end
    missing_options_str = ''; % Note: strjoin() unavailable in Matlab 2009.
    for option=missing_options
      missing_options_str = [missing_options_str, ' ', option{1}];
    end
    error(['Required option set not satisfied. The specified device `' device_serial '` ', ...
           'has the `' installed_options_str '` options installed but is missing ', ...
           'the required options `' missing_options_str '`. ' required_err_msg])
  end
end

% The maximum API level supported by the device class, e.g., MF.
apilevel_device = props.apilevel;

% Ensure that we connect on an compatible API Level (from where
% ziCreateAPISession() was called).
apilevel = min(apilevel_device, maximum_supported_apilevel);
% See the LabOne Programming Manual for an explanation of API levels.

% Create a connection to a Zurich Instruments Data Server (a API session)
% using the device's default connectivity properties.
ziDAQ('connect', props.serveraddress, props.serverport, apilevel);

if isempty(props.connected)
  fprintf('Will try to connect device `%s` on interface `%s`.\n', props.deviceid, props.interfaces{1})
  ziDAQ('connectDevice', props.deviceid, props.interfaces{1});
end

end

function missing_options = regex_option_diff(required_options, installed_options)
  missing_options = {};
  for i=1:length(required_options)
    if all(cellfun('isempty', regexp(required_options(i), installed_options)))
      missing_options(end+1) = required_options(i);
    end
  end
end
