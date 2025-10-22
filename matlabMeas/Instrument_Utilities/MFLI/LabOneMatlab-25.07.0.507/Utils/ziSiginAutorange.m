function range = ziSiginAutorange(device, in_channel)
% ZISIGINAUTORANGE Perform an autorange on the specified device's input channel
%
% RANGE = ZISIGINAUTORANGE(DEVICE, IN_CHANNEL)
%
%   Perform an automatic adjustment of DEVICE's signal input channel IN_C and
%   return the final RANGE set. This utility function starts the functionality
%   implemented in the device's firmware and waits until it has completed. The
%   range is set by the firmware based on the measured input signal's
%   amplitude measured over approximately 100 ms.
%
%   Requirements:
%
%     1. A device type that supports autorange functionality on the firmware
%     level, e.g., UHFLI, MFLI, MFIA. For HF2 Instruments see the example
%     hf2_example_autorange().
%
%     2. The ziDAQ API Session (connection to the device's Data Server) has
%     already been initialised.
%
%   Input arguments:
%
%     DEVICE (str): The device ID on which to perform the signal input
%     autorange, e.g., 'dev2006'
%
%     IN_CHANNEL (int): The index of the signal input channel to autorange.
%
%   Raises:
%
%     Error: If the functionality is not supported by the device or an
%       invalid in_channel was specified.
%
%     Error: If autorange functionality does not complete within the
%     timeout.
%
%   Example:
%
%     device = 'dev2006'
%     ziCreateAPISession('dev2006', 5);
%     input_channel = 0
%     ziSiginAutorange(device, input_channel)
%
% See also ZICREATEAPISESSION, EXAMPLE_SCOPE

% Check the device has the specified input channel.
  available_sigin_channels = ziDAQ('listNodes', ['/' device '/sigins', 0]);
  c = ''; for i=available_sigin_channels; c = [c, ]; end
  error_message = ['Channel `', in_channel, '` is unavailable on device `' device '`. ' ...
                   'Available channels: `' c '`.'];
  assert(any(cellfun(@(x)~isempty(x), regexp(num2str(in_channel), available_sigin_channels))), error_message);

% Check the device supports the autorange node.
  autorange_path = sprintf('/%s/sigins/%s/autorange', device, num2str(in_channel));
  error_message = ['The signal input autorange node `' autorange_path ...
                   '` was not returned by listNodes(). Please check the device supports' ...
                   'autorange firmware functionality (HF2 Instruments do not). ' ...
                   'For HF2 Instruments see hf2_example_autorange.m.'];
  result = ziDAQ('listNodes', autorange_path, 7);
  regexpi(autorange_path, result);
  assert(any(cellfun(@(x)~isempty(x), regexpi(autorange_path, result))), error_message);

% Start the firmware autorange functionality:
  ziDAQ('setInt', autorange_path, 1);

% Sync: Ensure value has taken effect on device before continuing. The node
% /device/sigins/in_channel/autorange has the value of 1 until an appropriate
% range has been configured by the device.
  ziDAQ('sync');

  tic;
  t0 = toc;
  timeout = 60.0;  % seconds
% Wait until the autorange routing on the device has finished.
  while (ziDAQ('getInt', autorange_path) == 1)
    pause(0.010);
    tNow = toc;
    if tNow - t0 > timeout;
      error_message = ['Signal input autorange (`', autorange_path '`) failed to ', ...
                       'complete after after `' double2str(timeout) '` seconds.']
      error(error_message);
    end
  end

  range = ziDAQ('getDouble', ['/' device '/sigins/' num2str(in_channel) '/range']);
end
