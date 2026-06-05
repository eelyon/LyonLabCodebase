function output_mixer_channel = ziGetDefaultSigoutMixerChannel(discovery_props, output_channel)
% ZIGETDEFAULTSIGOUTMIXERCHANNEL Return instrument's default signal output mixer channel
%
% ZIGETDEFAULTSIGOUTMIXERCHANNEL(DISCOVERY_PROPS, OUTPUT_CHANNEL)
%
% Return the instrument's default Signal Output mixer channel used by the
% hardware Signal Output channel specified by OUTPUT_CHANNEL. DISCOVERY_PROPS
% are the device's discovery properties as returned by `discoveryGet`.
%
% EXAMPLE
%
% device_id = 'dev2006';
% % Determine the device identifier from it's ID.
% device = lower(ziDAQ('discoveryFind', device_id));
% % Get the device's default connectivity properties.
% discovery_props = ziDAQ('discoveryGet', device);
% mixer_channel = ziGetDefaultSigoutMixerChannel(discovery_props, output_channel)
%
% Copyright 2008-2018 Zurich Instruments AG

if ~exist('discovery_props', 'var')
  error('Required input argument `discovery_props` not specified.');
end

if ~exist('output_channel', 'var')
  error('Required input argument `output_channel` specified. This specifies the Signal Output HW channel.');
end

% Define which output channels the instrument has based on its devtype.
if strncmp(discovery_props.devicetype, 'MF', 2)
    valid_output_channels = [0];
else
    valid_output_channels = [0, 1];
end

assert(ismember(output_channel, valid_output_channels), ...
       'Invalid value for output_channel: %d. Valid values: %s.', output_channel, mat2str(valid_output_channels));

% The logic below assumes that the device type is one of the following.
supported_devices = {'HF2IS', 'HF2LI', 'UHFLI', 'UHFAWG', 'UHFQA', 'MFIA', 'MFLI'};
assert(~isempty(strmatch(discovery_props.devicetype, supported_devices)), ...
       'Device type %s not supported. Supported device types: %s', ...
       discovery_props.devicetype, strjoin(supported_devices, ', '));

% Define default the default output mixer channel based on the device type and its options.
if any(strncmp(discovery_props.devicetype, {'UHFLI', 'UHFAWG'}, 5)) & ~ismember('MF', discovery_props.options)
  if output_channel == 0
    output_mixer_channel = '3';
  else
    output_mixer_channel = '7';
  end
elseif strncmp(discovery_props.devicetype, 'HF2LI', 5) & ~ismember('MF', discovery_props.options)
  if output_channel == 0
    output_mixer_channel = '6';
  else
    output_mixer_channel = '7';
  end
elseif strncmp(discovery_props.devicetype, 'MF', 2) & ~ismember('MD', discovery_props.options)
    output_mixer_channel = '1';
else
  if output_channel == 0
    output_mixer_channel = '0';
  else
    output_mixer_channel = '1';
  end
end

end
