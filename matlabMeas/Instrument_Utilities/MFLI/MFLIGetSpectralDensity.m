function [data_fft] = MFLIGetSpectralDensity(device_id, varargin)
%% Measure Power Spectral Density with MFLI Scope/DAQ
% MFLIGetPSD record Power Spectral Density using the Scope Module
%
% Get assembled Spectral Density shots from the device specified by DEVICE_ID using
% the Scope Module. DEVICE_ID should be a string, e.g.,
% 'dev1000' or 'uhf-dev1000'.
%
% NOTE Please ensure that the ziDAQ folders 'Driver' and 'Utils' are in your
% Matlab path. To do this (temporarily) for one Matlab session please navigate
% to the ziDAQ base folder containing the 'Driver', 'Examples' and 'Utils'
% subfolders and run the Matlab function ziAddPath().
% >>> ziAddPath;
%
% Use either of the commands:
% >>> help ziDAQ
% >>> doc ziDAQ
% in the Matlab command window to obtain help on all available ziDAQ commands.

clear ziDAQ;

if ~exist('device_id', 'var')
    error(['No value for device_id specified. The first argument to the ' ...
           'example should be the device ID on which to run the example, ' ...
           'e.g. ''dev1000'' or ''uhf-dev1000''.'])
end

% Check the ziDAQ MEX (DLL) and Utility functions can be found in Matlab's path.
if ~(exist('ziDAQ') == 3) && ~(exist('ziCreateAPISession', 'file') == 2)
    fprintf('Failed to either find the ziDAQ mex file or ziDevices() utility.\n')
    fprintf('Please configure your path using the ziDAQ function ziAddPath().\n')
    fprintf('This can be found in the API subfolder of your LabOne installation.\n');
    fprintf('On Windows this is typically:\n');
    fprintf('C:\\Program Files\\Zurich Instruments\\LabOne\\API\\MATLAB2012\\\n');
    return
end

% The API level supported by this function.
apilevel_example = 6;
% This example can't run with HF2 Instruments.
required_devtype = 'UHF|MF'; % Regular expression of supported instruments.
required_options = {}; % No special options required.
required_err_msg = ['This script is incompatible with HF2 Instruments: The ' ...
                    'HF2 Data Server does not support API Levels > 1, which ' ...
                    'is required to use the extended scope data structure. ' ...
                    'See hf2_example_scope().'];
% Create an API session; connect to the correct Data Server for the device.
[device, ~] = ziCreateAPISession(device_id, apilevel_example, ...
                                     'required_devtype', required_devtype, ...
                                     'required_options', required_options, ...
                                     'required_err_msg', required_err_msg);
ziApiServerVersionCheck();

% Enable the API's log.
ziDAQ('setDebugLevel', 0);

% Create a base configuration: Disable all available outputs, awgs,
% demods, scopes,...
ziDisableEverything(device);

%% Configure the device ready for this experiment
% Define parameters relevant to this example. Default values specified by the
% inputParser below are overwritten if specified as name-value pairs via the
% `varargin` input argument.
p = inputParser;
isnonnegscalar = @(x) isnumeric(x) && isscalar(x) && (x > 0);

% The PSD start frequency is always 0 Hz and its stop frequency is half
% the scope's sample rate.
p.addParameter('scope_samplerate', 4, isnonnegscalar);
p.addParameter('scope_lengthpts', 16384, @isnumeric);
p.addParameter('min_num_records', 1, @isnumeric);
p.addParameter('averager', 0, @isnumeric);
p.addParameter('temp', 296, @isnumeric);
p.addParameter('gainCryo', 1, @isnumeric);
p.addParameter('gainFEMTO', 1, @isnumeric);
p.addParameter('saveData', 0, @isnumeric)

p.parse(varargin{:});

gain = p.Results.gainCryo*p.Results.gainFEMTO;

in_channel = '0';        % signal input channel
scope_in_channel = '0';    % scope input channel

% Configure the signal inputs
ziDAQ('setInt', ['/' device '/sigins/' in_channel '/imp50'], 0);
ziDAQ('setInt', ['/' device '/sigins/' in_channel '/ac'], 1);
ziDAQ('setInt',    ['/' device '/sigins/' in_channel '/autorange'], 1);
% Perform a global synchronisation between the device and the data server:
% Ensure that the signal input configuration has taken effect before
% calculating the signal input autorange.
ziDAQ('sync');

% Perform an automatic adjustment of the signal inputs range based on
% the measured input signal's amplitude measured over approximately
% 100 ms. This is important to obtain the best bit resolution on the
% signal inputs of the measured signal in the scope.
ziSiginAutorange(device, in_channel);

% Configure the scope via the /device/scopes/0 branch
% 'length' : the length of each segment
ziDAQ('setInt', ['/' device '/scopes/0/length'],  int64(p.Results.scope_lengthpts));
% 'channel' : select the scope channel(s) to enable.
ziDAQ('setInt',    ['/' device '/scopes/0/channel'], bitshift(1, str2double(in_channel)));
% 'channels/0/bwlimit' : bandwidth limit the scope data. Enabling bandwidth
% limiting avoids antialiasing effects due to subsampling when the scope
% sample rate is less than the input channel's sample rate.
ziDAQ('setInt',    ['/' device '/scopes/0/channels/' scope_in_channel '/bwlimit'], 1);
% 'channels/0/inputselect' : the input channel for the scope:
%   0 - signal input 1
%   1 - signal input 2
%   2, 3 - trigger 1, 2 (front)
%   8-9 - auxiliary inputs 1-2
ziDAQ('setInt',    ['/' device '/scopes/0/channels/' scope_in_channel '/inputselect'], str2double(in_channel));
% 'time' : timescale of the wave, sets the sampling rate to 60MHz/2**time.
%   0 - sets the sampling rate to 60 MHz
%   1 - sets the sampling rate to 30 MHz
%   ...
%   5 - sets the sampling rate to 1.88 MHz
%   ...
%   16 - sets the samptling rate to 916 Hz
scope_time = p.Results.scope_samplerate;
ziDAQ('setInt',  ['/' device '/scopes/0/time'], scope_time);
% 'single' : only get a single scope record.
ziDAQ('setInt',    ['/' device '/scopes/0/single'], 0);
% 'trigenable' : enable the scope's trigger (boolean).
ziDAQ('setInt',    ['/' device '/scopes/0/trigenable'], 0);
% 'trigholdoff' : the scope hold off time inbetween acquiring triggers (still
% relevant if triggering is disabled).
ziDAQ('setDouble', ['/' device '/scopes/0/trigholdoff'], 0.05);

% Perform a global synchronisation between the device and the data server:
% Ensure that the settings have taken effect on the device before issuing the
% ``poll`` command and clear the API's data buffers to remove any old data.
ziDAQ('sync');

% Initialize and configure the Scope Module.
scopeModule = ziDAQ('scopeModule');
% 'mode' : Scope data processing mode.
% 0 - Pass through scope segments assembled, returned unprocessed,
%     non-interleaved.
% 1 - Time domain with averaging, scope recording assembled, scaling applied, averaged, if averaging is
%     enabled, using the method set by 'averager/method'.
% 2 - Not yet supported.
% 3 - As for mode 1, except an FFT is applied to every segment of the scope
%     recording.
ziDAQ('set', scopeModule, 'mode', 1);
% 'averager/method' : Averaging method to use.
%   0 - exponential averaging using the weight specified by 'averager/weight'.
%   1 - uniform averaging. The 'averager/weight' value has no effect but must be greater than 1 to enable everaging.
ziDAQ('set', scopeModule, 'averager/method', 1)
% 'averager/weight' : Averager behaviour for exponential averaging method.
%   weight=1 - don't average.
%   weight>1 - average the scope record segments using an exponentially weighted moving average.
ziDAQ('set', scopeModule, 'averager/weight', 10);
% 'averager/enable' : Activate averaging
ziDAQ('set', scopeModule, 'averager/enable', p.Results.averager);
% 'historylength' : The number of scope records to keep in
%   the Scope Module's memory, when more records arrive in the Module
%   from the device the oldest records are overwritten.
ziDAQ('set', scopeModule, 'historylength', 20);

% Subscribe to the scope's data in the module.
wave_nodepath = ['/' device '/scopes/0/wave'];
ziDAQ('subscribe', scopeModule, wave_nodepath);

% Set the Scope Module's mode to return frequency domain data.
ziDAQ('set', scopeModule, 'mode', 3);
% Use a Hann window function.
ziDAQ('set', scopeModule, 'fft/window', 1);
% Set power correction
ziDAQ('set', scopeModule, 'fft/powercompensation', 1);
% Enable Spectral Density
ziDAQ('set', scopeModule, 'fft/spectraldensity', 1);
% Disable Power
ziDAQ('set', scopeModule, 'fft/power', 0);

% Enable the scope and read the scope data arriving from the device; the Scope
% Module will additionally perform an FFT on the data. Note: The other module
% parameters are already configured and the required data is already subscribed
% from above.
fprintf('Obtaining FFT''d scope data with triggering disabled...\n')
data_fft = getScopeRecords(device, scopeModule, p.Results.min_num_records);
if ziCheckPathInData(data_fft, wave_nodepath)
  checkScopeRecordFlags(data_fft.(device).scopes(1).wave);
end

% Stop the scope module.
ziDAQ('finish', scopeModule);

% Clear the module's thread. It may not be used again.
% Release module resources. Especially important if modules are created
% inside a loop to prevent excessive resource consumption.
ziDAQ('clear', scopeModule);

clockbase = ziDAQ('getInt', ['/' device '/clockbase']);

% Plot the FFT'd scope data with triggering disabled.
fig = figure; clf;
num_records_fft = 0;
if ziCheckPathInData(data_fft, ['/' device '/scopes/0/wave'])
  records_fft = data_fft.(device).scopes(1).wave;
  num_records_fft = length(records_fft);
  plotScopeRecords(records_fft, str2num(scope_in_channel), scope_time, clockbase, gain);
end
annotation('textbox',[0.2 0.5 0.3 0.3],'String',[num2str(p.Results.temp),'K, x',num2str(gain),' total gain, ', num2str(num_records_fft),' records'],'FitBoxToText','on');
title('\bf Spectral Density of Scope records');
grid on;
box on;
xlabel('Frequency (Hz)');
fprintf('Number of scope records with triggering disabled (and FFT''d): %d.\n', num_records_fft);

if p.Results.saveData == 1
    saveData(fig,'SpectralDensity');
end
end

function data = getScopeRecords(device, scopeModule, num_records)
% GETSCOPERECORDS  Obtain scope records from device using an Scope Module.

  % Tell the module to be ready to acquire data; reset the module's progress to 0.0.
  ziDAQ('execute', scopeModule);

  % Enable the scope: Now the scope is ready to record data upon
  % receiving triggers.
  ziDAQ('setInt', ['/' device '/scopes/0/enable'], 1);
  ziDAQ('sync');

  time_start = tic;
  timeout = 30;  % [s]
  records = 0;
  % Wait until the Scope Module has received and processed the desired number of records.
  while records < num_records
    pause(0.5)
    records = ziDAQ('getInt', scopeModule, 'records');
    progress = ziDAQ('progress', scopeModule);
    fprintf(['Scope module has acquired %d records (requested %d). ' ...
             'Progress of current segment %.1f %%.\n'], records, ...
            num_records, 100*progress);
    % Advanced use: It's possible to read-out data before all records have
    % been recorded (or even all segments in a multi-segment record
    % have been recorded). Note that complete records are removed
    % from the Scope Module and can not be read out again; the
    % read-out data must be managed by the client code. If a
    % multi-segment record is read-out before all segments have been
    % recorded, the wave data has the same size as the complete data
    % and scope data points currently unacquired segments are equal
    % to 0.
    %
    % data = ziDAQ('read', scopeModule);
    % wave_nodepath = ['/' device '/scopes/0/wave'];
    % if wave_nodepath in data:
    %   Do something with the data...
    if toc(time_start) > timeout
      % Break out of the loop if for some reason we're no longer receiving
      % scope data from the device.
      fprintf('\nScope Module did not return %d records after %f s - forcing stop.', num_records, timeout);
      break
    end
  end
  ziDAQ('setInt', ['/' device '/scopes/0/enable'], 0);

  % Read out the scope data from the module.
  data = ziDAQ('read', scopeModule);

  % Stop the module; to use it again we need to call execute().
  ziDAQ('finish', scopeModule);

end

function plotScopeRecords(scope_records, scope_in_channel, scope_time, clockbase, gain)
% plotScopeRecords Plot the scope records.
  num_records = length(scope_records);
  c = hsv(num_records);
  for ii=num_records  % ii = 1:num_records
    totalsamples = double(scope_records{ii}.totalsamples);
    if ~bitand(scope_records{ii}.channelmath(scope_in_channel+1), 2)
      dt = scope_records{ii}.dt;
      % The timestamp is the last timestamp of the last sample in the scope segment.
      timestamp = double(scope_records{ii}.timestamp);
      triggertimestamp = double(scope_records{ii}.triggertimestamp);
      t = linspace(-totalsamples, 0, totalsamples)*dt + (timestamp - ...
                                                        triggertimestamp)/double(clockbase);
      plot(1e6*t, scope_records{ii}.wave(:, scope_in_channel+1), 'color', c(ii, :));
      hold on;
      plot([0.0, 0.0], get(gca, 'ylim'), '--k');
    elseif bitand(scope_records{ii}.channelmath(scope_in_channel+1), 2)
      scope_rate = double(clockbase)/2^scope_time;
      f = linspace(0, scope_rate/2, totalsamples);
      loglog(f, scope_records{ii}.wave(:, scope_in_channel+1)/gain*1e9, 'color', 'r'); % c(ii,:)
      xlim([f(1),f(end)]);
      hold on;
    end
  end
  ylabel('Spectral Density (nV/\surd{Hz})');
end

function checkScopeRecordFlags(scope_records)
% CHECKSCOPERECORDFLAGS report if the scope records contain corrupt data
%
% CHECKSCOPERECORDFLAGS(SCOPE_RECORDS)
%
%   Loop over all records and print a warning to the console if an error bit in
%   flags has been set.
  num_records = length(scope_records);
  for ii=1:num_records
    if bitand(scope_records{ii}.flags, 1)
      fprintf('Warning: Scope record %d/%d flag indicates dataloss.', ii, num_records);
    end
    if bitand(scope_records{ii}.flags, 2)
      fprintf('Warning: Scope record %d/%d indicates missed trigger.', ii, num_records);
    end
    if bitand(scope_records{ii}.flags, 3)
      fprintf('Warning: Scope record %d/%d indicates transfer failure (corrupt data).', ii, num_records);
    end
    totalsamples = scope_records{ii}.totalsamples;
    for cc=1:size(scope_records{ii}.wave, 2)
      % Check that the wave in each scope channel contains the expected number of samples.
      assert(length(scope_records{ii}.wave(:, cc)) == totalsamples, ...
             'Scope record %d/%d size does not match totalsamples.', ii, num_records);
    end
  end
end