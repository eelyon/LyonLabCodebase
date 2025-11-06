function data = MFLIFreqSweep(device_id, varargin)
% MFLIFREQSWEEP Perform a frequency sweep using ziDAQ's sweep module
%
% USAGE DATA = MFLIFREQSWEEP(DEVICE_ID)
% Call data.device_id.demods.sample{1}.r to get r data
%
% Perform a frequency sweep and gather demodulator data. DEVICE_ID should be a string,
% e.g., 'dev1000' or 'uhf-dev1000'.
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

% The API level supported by this example.
apilevel_example = 6;
% Create an API session; connect to the correct Data Server for the device.
[device, props] = ziCreateAPISession(device_id, apilevel_example);
ziApiServerVersionCheck();

branches = ziDAQ('listNodes', ['/' device ], 0);
if ~any(strcmpi([branches], 'DEMODS'))
  data = [];
  fprintf('\nThis example requires lock-in functionality which is not available on %s.\n', device);
  return
end

% Define parameters. Default values specified by the
% inputParser below are overwritten if specified as name-value pairs via the
% `varargin` input argument.
p = inputParser;
isnonnegscalar = @(x) isnumeric(x) && isscalar(x) && (x > 0);

% Save data (1) or not (0)
p.addParameter('savedata', 0, @isnumeric);

% The value used for the Sweeper's 'samplecount' parameter: This
% specifies the number of points that will be swept (i.e., the number of
% frequencies swept in a frequency sweep).
p.addParameter('sweep_samplecount', 500, isnonnegscalar);

% The value used for the Sweeper's 'settling/inaccuracy' parameter: This
% defines the settling time the sweeper should wait before changing a sweep
% parameter and recording the next sweep data point. The settling time is
% calculated from the specified proportion of a step response function that
% should remain. The value provided here, 0.001, is appropriate for fast and
% reasonably accurate amplitude measurements. For precise noise measurements
% it should be set to ~100n.
p.addParameter('sweep_inaccuracy', 0.001, @isnumeric);

% The signal output mixer amplitude, [V].
p.addParameter('amplitude', 0.002, @isnumeric);
% Set the sweep's start frequency
p.addParameter('sweep_startfreq', 10e3, @isnumeric);
% Set the sweep's stop frequency
p.addParameter('sweep_stopfreq', 3e6, @isnumeric);
% Set the demodulator time constant [s]
p.addParameter('tc', 0.007, @isnumeric);
% Set the demodulation rate
p.addParameter('demod_rate', 13e3, @isnumeric);
% Set the filter order
p.addParameter('order', 1, @isnumeric);
% Settling time
p.addParameter('settlingtime', 0.035, @isnumeric);

p.parse(varargin{:});

% Define some other helper parameters.
demod_c = '0'; % demod channel, for paths on the device
demod_idx = str2double(demod_c)+1; % 1-based indexing, to access the data
out_c = '0'; % signal output channel
% Get the value of the instrument's default Signal Output mixer channel.
out_mixer_c = num2str(ziGetDefaultSigoutMixerChannel(props, str2num(out_c)));
in_c = '0'; % signal input channel
osc_c = '0'; % oscillator

% tc = 0.007; % [s]
% demod_rate = 13e3;
% order = 4;

% Create a base configuration: Disable all available outputs, awgs,
% demods, scopes,...
ziDisableEverything(device);

%% Configure the device ready for this experiment.
ziDAQ('setInt', ['/' device '/sigins/' in_c '/imp50'], 0);
ziDAQ('setInt', ['/' device '/sigins/' in_c '/ac'], 1);
ziDAQ('setInt',    ['/' device '/sigins/' in_c '/autorange'], 1);
ziDAQ('setInt', ['/' device '/sigouts/' out_c '/on'], 1);
ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/range'], 0.01);
ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/*'], 0);
ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/' out_mixer_c], p.Results.amplitude);
ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/enables/' out_mixer_c], 1);
ziDAQ('setInt', ['/' device '/sigins/' in_c '/diff'], 0);
ziDAQ('setInt', ['/' device '/sigouts/' out_c '/add'], 0);
ziDAQ('setDouble', ['/' device '/demods/*/phaseshift'], 0);
ziDAQ('setInt', ['/' device '/demods/*/order'], p.Results.order);
ziDAQ('setDouble', ['/' device '/demods/' demod_c '/rate'], p.Results.demod_rate);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/harmonic'], 1);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/enable'], 1);
ziDAQ('setInt', ['/' device '/demods/*/oscselect'], str2double(osc_c));
ziDAQ('setInt', ['/' device '/demods/*/adcselect'], str2double(in_c));
ziDAQ('setDouble', ['/' device '/demods/*/timeconstant'], p.Results.tc);
ziDAQ('setDouble', ['/' device '/oscs/' osc_c '/freq'], p.Results.sweep_startfreq); % [Hz]

%% Sweeper settings
% Create a thread for the sweeper
h = ziDAQ('sweep');
% Device on which sweeping will be performed
ziDAQ('set', h, 'device', device);
% Sweeping setting is the frequency of the output signal
ziDAQ('set', h, 'gridnode', ['oscs/' osc_c '/freq']);
% Start frequency = 1 kHz
ziDAQ('set', h, 'start', p.Results.sweep_startfreq);
% Stop frequency
ziDAQ('set', h, 'stop', p.Results.sweep_stopfreq);
% Perform sweeps consisting of sweep_samplecount measurement points (i.e.,
% record the subscribed data for sweep_samplecount different frequencies).
ziDAQ('set', h, 'samplecount', p.Results.sweep_samplecount);
% Perform one single sweep.
ziDAQ('set', h, 'loopcount', 1);
% Logarithmic sweep mode.
ziDAQ('set', h, 'xmapping', 1);
% Binary scan type.
ziDAQ('set', h, 'scan', 1);
% Set a fixed settling/time.
ziDAQ('set', h, 'settling/time', p.Results.settlingtime);
% The setting/inaccuracy defines the settling time the sweeper should
% wait before changing a sweep parameter and recording the next sweep data
% point, see the comments at the inputParser at the beginning of this function
% for a further explanation.
% Note: The actual time the sweeper waits before
% recording data is the maximum time specified by settling/time and
% defined by settling/inaccuracy.
ziDAQ('set', h, 'settling/inaccuracy', p.Results.sweep_inaccuracy);
% Minimum time to record and average data is 50 time constants.
ziDAQ('set', h, 'averaging/tc', 1);
% Minimal number of samples that we want to record and average is 100. Note,
% the number of samples used for averaging will be the maximum number of
% samples specified by either averaging/tc or averaging/sample.
ziDAQ('set', h, 'averaging/sample', 1);
% Use automatic bandwidth control for each measurement.
ziDAQ('set', h, 'bandwidthcontrol', 2);
% For fixed bandwidth, set bandwidthcontrol to 1 and specify a bandwidth.
% For manual bandwidth control, set  bandwidthcontrol to 2. bandwidth must also be set
% to a value > 0 although it is ignored. Otherwise Auto control is automatically chosen (for backwards compatibility reasons).
% ziDAQ('set', h, 'bandwidth', 100);
% Sets the bandwidth overlap mode (default 0). If enabled, the bandwidth of a
% sweep point may overlap with the frequency of neighboring sweep points. The
% effective bandwidth is only limited by the maximal bandwidth setting and
% omega suppression. As a result, the bandwidth is independent of the number
% of sweep points. For frequency response analysis bandwidth overlap should be
% enabled to achieve maximal sweep speed (default: 0). 0 = Disable, 1 = Enable.
ziDAQ('set', h, 'bandwidthoverlap', 0);
% Subscribe to the node from which data will be recorded.
ziDAQ('subscribe', h, ['/' device '/demods/' demod_c '/sample']);

% Start sweeping.
ziDAQ('execute', h);

data = [];
frequencies = nan(1, p.Results.sweep_samplecount);
r = nan(1, p.Results.sweep_samplecount);
theta = nan(1, p.Results.sweep_samplecount);

fig = figure; clf;
timeout = 60;
t0 = tic;
% Read and plot intermediate data until the sweep has finished.
while ~ziDAQ('finished', h)
    pause(1);
    tmp = ziDAQ('read', h);
    fprintf('Sweep progress %0.0f%%\n', ziDAQ('progress', h) * 100);
    % Using intermediate reads we can plot a continuous refinement of the ongoing
    % measurement. If not required it can be removed.
    if ziCheckPathInData(tmp, ['/' device '/demods/' demod_c '/sample'])
        sample = tmp.(device).demods(demod_idx).sample{1};
        if ~isempty(sample)
            data = tmp;
            % Get the magnitude and phase of demodulator from the sweeper result.
            r = sample.r;
            theta = sample.phase;
            % Frequency values at which measurement points were taken
            frequencies = sample.grid;
            valid = ~isnan(frequencies);
            plot_data(frequencies(valid), r(valid), theta(valid), '.-')
            drawnow;
        end
    end
    if toc(t0) > timeout
        ziDAQ('clear', h);
        error('Timeout: Sweeper failed to finish after %f seconds.', timeout)
    end
end
fprintf('Sweep completed after %.2f s.\n', toc(t0));

% Read the data. This command can also be executed during the waiting (as above).
tmp = ziDAQ('read', h);

% Unsubscribe from the node; stop filling the data from that node to the
% internal buffer in the Data Server.
ziDAQ('unsubscribe', h, ['/' device '/demods/*/sample']);

% Process any remainging data returned by read().
if ziCheckPathInData(tmp, ['/' device '/demods/' demod_c '/sample'])
    sample = tmp.(device).demods(demod_idx).sample{1};
    if ~isempty(sample)
        % Extracting R component and phase of input signal
        % As several sweeps may be returned, a cell array is used.
        % In this case we pick the first sweep result by {1}.
        data = tmp;
        r = sample.r;
        theta = sample.phase;
        % Frequency values at which measurement points were taken
        frequencies = sample.grid;
        % Plot the final result
        plot_data(frequencies, r, theta, '-')
    end
end

if p.Results.savedata == 1
    saveData(fig, 'MFLIFreqSweep');
end

% Release module resources. Especially important if modules are created
% inside a loop to prevent excessive resource consumption.
ziDAQ('clear', h);

% Sweeper module returns a structure with following elements:
% * timestamp -> Time stamp data [uint64]. Divide the timestamp by the
% device's clockbase in order to get seconds, the clockbase can be obtained
% via: clockbase = double(ziDAQ('getInt', ['/' device '/clockbase']));
% * x -> Demodulator x value in volt [double]
% * y -> Demodulator y value in volt [double]
% * r -> Demodulator r value in Vrms [double]
% * phase ->  Demodulator theta value in rad [double]
% * xstddev -> Standard deviation of demodulator x value [double]
% * ystddev -> Standard deviation of demodulator x value [double]
% * rstddev -> Standard deviation of demodulator r value [double]
% * phasestddev -> Standard deviation of demodulator theta value [double]
% * grid ->  Values of sweeping setting (frequency values at which
% demodulator samples where recorded) [double]
% * bandwidth ->  Filter bandwidth for each measurement point [double].
% * tc ->  Filter time constant for each measurement point [double].
% * settling ->  Waiting time for each measurement point [double]
% * frequency ->  Oscillator frequency for each measurement point [double]
% (in his case same as grid).
% * frequencystddev -> Standard deviation of oscillator frequency
% * realbandwidth -> The actual bandwidth set
% Assuming we're doing a frequency sweep:
% * settimestamp -> The time at which we verify that the frequency for the
% current sweep point was set on the device (by reading back demodulator data)
% * nexttimestamp -> The time at which we can get the data for that sweep point.
% i.e., nexttimestamp - settimestamp corresponds roughly to the
% demodulator filter settling time.

end

function plot_data(frequencies, r, theta, style)
% Plot data
clf
subplot(3, 1, 1)
s = semilogx(frequencies, r*2*sqrt(2), style);
set(s, 'LineWidth', 1.5)
set(s, 'Color', 'black');
grid on
xlabel('Frequency [Hz]')
ylabel('Amplitude [V_{pp}]')
xlim([frequencies(1),frequencies(end)])

subplot(3, 1, 2)
s = semilogx(frequencies, r/max(r), style);
set(s, 'LineWidth', 1.5)
set(s, 'Color', 'black');
grid on
xlabel('Frequency [Hz]')
ylabel('Amplitude [V_{pp}/max(V_{pp})]')
xlim([frequencies(1),frequencies(end)])

subplot(3, 1, 3)
s = semilogx(frequencies, theta*180/pi, style);
set(s, 'LineWidth', 1.5)
set(s, 'Color', 'black');
grid on
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
xlim([frequencies(1),frequencies(end)])
end
