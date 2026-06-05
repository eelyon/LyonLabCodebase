function data = MFLISweep2D(sweepTypes, starts, stops, steps, mfli_id, device_ids, ports, varargin)

%% Test command (FOR TESTING PURPOSES ONLY, NOT INDICATIVE OF ANY OTHER FUNCTIONALITY)
% sweep2DMeasSR830_Func({'Freq', 'ST'}, {1000, 0}, {10000, 1}, {1000, 0.1}, {SR830,SR830}, {{'Freq'},{'1'}}, 0.5, 5, SR830)
% sweep2DMeasSR830_Func({'ST','TM'}, {0,-2}, {-.75,-.75}, {-.05,.25},{DAC,DAC},{1,4},.03,10,{SR830},extraPorts)

%% Configure MFLI
clear ziDAQ;

if ~exist('mfli_id', 'var')
    error(['No value for mfli_id specified. Device ID is either' ...
        ' ''dev32021'' or ''dev32062''.'])
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

% The API level supported by this script.
apilevel_example = 6;
% Create an API session; connect to the correct Data Server for the device.
[device, props] = ziCreateAPISession(mfli_id, apilevel_example);
ziApiServerVersionCheck();

branches = ziDAQ('listNodes', ['/' device ], 0);
if ~any(strcmpi(branches, 'DEMODS'))
  sample = [];
  fprintf('\nThis script requires lock-in functionality which is not available on %s.\n', device);
  return
end

% Define parameters relevant to this script. Default values specified by the
% inputParser below are overwritten if specified as name-value pairs via the
% `varargin` input argument.
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% Filter order
p.addParameter('filter_order', 3, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.010, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 2e3, @isnumeric);
% The length of time we'll record data (synchronously) [s].
p.addParameter('poll_duration', 0.1, isnonneg);
% The length of time to accumulate subscribed data (by sleeping) before polling a second time [s].
% p.addParameter('sleep_duration', 1.0, isnonneg);
p.parse(varargin{:});
time_constant = p.Results.time_constant;
poll_duration = p.Results.poll_duration;

% Define some other helper parameters.
demod_c = '0'; % Demod channel, 0-based indexing for paths on the device.
demod_idx = str2double(demod_c) + 1; % 1-based indexing, to access the data.
in_c = '0'; % signal input channel
extref_c = '8'; % external reference channel - 8 for Aux In 1

% Create a base configuration: Disable all available outputs, awgs,
% demods, scopes,...
ziDisableEverything(device);

% Configure the device for this experiment.
ziDAQ('setInt', ['/' device '/sigins/' in_c '/ac'], 1);
% ziDAQ('setInt', ['/' device '/sigins/' in_c '/autorange'], 1);
% ziDAQ('setDouble', ['/' device '/sigins/' in_c '/range'], 2.0*amplitude);
ziDAQ('setInt', ['/' device '/demods/*/order'], p.Results.filter_order);
ziDAQ('setDouble', ['/' device '/demods/' demod_c '/rate'], p.Results.demod_rate);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/harmonic'], 1);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/enable'], 1);
ziDAQ('setInt', ['/' device '/demods/*/adcselect'], str2double(in_c));
ziDAQ('setDouble', ['/' device '/demods/*/timeconstant'], time_constant);
ziDAQ('setInt', ['/' device '/demods/1/adcselect'], str2double(extref_c));
ziDAQ('setInt', ['/' device '/extrefs/0/enable'], 1);
delay(0.5); % Wait for external reference to settle

%% Set up figure and start sweep loop
% Set up plot figure and meta data
plotHandle = initializeSR830Meas2D_Func(sweepTypes, starts, stops, steps);

metadata_struct.time_constant = time_constant;
metadata_struct.filter_order = p.Results.filter_order;
metadata_struct.demod_rate = p.Results.demod_rate;
metadata_struct.poll_duration = poll_duration;

if exist('controlDAC', 'var') == 1
    metadata_struct.controlDAC = evalin('base','controlDAC.channelVoltages;');
end
if exist('supplyDAC', 'var') == 1
    metadata_struct.supplyDAC = evalin('base','supplyDAC.channelVoltages;');
end

plotHandle.UserData = metadata_struct;

%% Read in Sweep types
% Each argument unpacked here needs braces to function correctly (i.e. sweepTypes = {'Freq', 'STM'})
[sweepType1, sweepType2] = sweepTypes{:};
[start1, start2] = starts{:};
[stop1, stop2] = stops{:};
[step1, step2] = steps{:};
[device_id1, device_id2] = device_ids{:};
[ports1, ports2] = ports{:};

%% First set of parameters to probe
if start1 > stop1 && step1 > 0
    step1 = -1*step1;
elseif start1 < stop1 && step1 < 0
    step1 = -1*step1;
end

paramVector1 = start1:step1:stop1;

%% Second set of parameters to probe
if start2 > stop2 && step2 > 0
    step2 = -1*step2;
elseif start2 < stop2 && step2 < 0
    step2 = -1*step2;
end

paramVector2 = start2:step2:stop2;

index1 = 1;
index2 = 1;

for value1 = paramVector1 % start loop of first parameter
    % Unsubscribe all streaming data.
    ziDAQ('unsubscribe', '*');

    for pIndex1 = 1:length(ports1)
        port1 = ports1{pIndex1};

        if pIndex1 == 1
            setVal(device_id1,port1,value1);
        else
            setVal(device_id1,port1,value1+deltaGateParam1);
        end
    end

    valueIndexVector2 = 1:length(paramVector2);

    if mod(valueIndex1, 2) == 0
        valueIndexVector2 = fliplr(1:length(paramVector2));
    end

    for value2 = paramVector2 % loops through 2nd parameter

        for pIndex2 = 1:length(ports2)
            port2 = ports2{pIndex2};
            if exist('extraPorts','var')
                port4 = ports4{pIndex2};
            end

            if pIndex2 == 1
                if ~exist('extraPorts','var')
                    setVal(device_id2,port2,value2);
                else
                    delta = value2/2;
                    setVal(device_id2,port2,centerV+delta);
                    setVal(device_id2,port4,centerV-delta);
                end
            else
                setVal(device_id2, port2, value2+deltaGateParam2);
            end

            delay(10*time_constant);

        end

        %% Initialize average vectors that gets reset for the repeating for loop
        data = [];
        %% Repeating for loop - changing repeat increases the number of averages to perform per point.
        %% Query SR830 for Real/Imag data, calculate Magnitude and place in vectors
        Mag = getSR830MagData(readSR830);


    
    %     sigDACRamp(device,port,value,5,1100);
    %     setVal(device_id, port, value);
    
        % Perform a global synchronisation between the device and the data server:
        % Ensure that the settings have taken effect on the device before issuing the
        % ``poll`` command and clear the API's data buffers to remove any old
        % data. Note: ``sync`` must be issued after waiting for the demodulator filter
        % to settle above.
        ziDAQ('sync');
    
        % Get data from MFLI
        % Subscribe to the demodulator sample.
        ziDAQ('subscribe', ['/' device '/demods/' demod_c '/sample']);
        
        % Poll data for poll_duration seconds.
        poll_timeout = 500;
        data = ziDAQ('poll', poll_duration, poll_timeout);
        
        if ziCheckPathInData(data, ['/' device '/demods/' demod_c '/sample'])
            sample = data.(device).demods(demod_idx).sample;
        else
            sample = [];
        end

        Xrms = mean(sample.x);
        Yrms = mean(sample.y);
        Rrms = sqrt(Xrms.^2+Yrms.^2); % Magnitude in rms
    
        x(index) = Xrms;
        y(index) = Yrms;
        
        phi = rad2deg(atan2(real(Yrms),real(Xrms))); % Phase in degrees
        stdRrms = sqrt(stdXrms.^2+stdYrms.^2); % Magnitude error in rms
        stdPhi = sqrt(1/(Xrms.^2+Yrms.^2).^2*(Yrms.^2*stdXrms.^2+Xrms.^2*stdYrms.^2)); % Phase error in degrees
    
        xvolts(index) = value;
        mag(index) = Rrms;
        phase(index) = phi;
        stdm(index) = stdRrms;
        stdphase(index) = stdPhi;
    
        %% Place data in repeat vectors that get averaged
        magVectorRepeat  = Mag;
        plotHandle.CData(valueIndex1, valueIndex2) = mean(magVectorRepeat);

        index1 = index1 + 1;
    end
    index2 = index2 + 1;
end

saveData(gcf,[genSR830PlotName(sweepType1), '-over-', genSR830PlotName(sweepType2)])

end

function mag = getSR830MagData(readSR830)
    mag = sqrt(readSR830.SR830queryX()^2 + readSR830.SR830queryY()^2);
    delay(.001);
end