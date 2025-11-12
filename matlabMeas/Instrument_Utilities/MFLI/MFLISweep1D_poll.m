function [avgxs,avgys,stdxs,stdys] = MFLISweep1D_poll(sweepType,start,stop,step,mfli_id,device_id,port,doBackAndForth,varargin)
%MFLISweep1D Sweep function using ziDAQ poll function to return data for
%certain duration.
%   Detailed explanation goes here
% To change the digital lock in parameters like filter stages or tc, you
% need to change these in the varargin parameters

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
p.addParameter('filter_order', 2, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.10, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 1e3, @isnumeric);
% The length of time we'll record data (synchronously) [s].
p.addParameter('poll_duration', 5, isnonneg);
% The length of time to accumulate subscribed data (by sleeping) before polling a second time [s].
% p.addParameter('sleep_duration', 1.0, isnonneg);
p.parse(varargin{:});
time_constant = p.Results.time_constant;
poll_duration = p.Results.poll_duration;
demod_rate = p.Results.demod_rate;

% Define some other helper parameters.
demod_c = '0'; % Demod channel, 0-based indexing for paths on the device.
demod_idx = str2double(demod_c) + 1; % 1-based indexing, to access the data.
in_c = '0'; % signal input channel
extref_c = '8'; % external reference channel - 8 for Aux In 1

% Create a base configuration: Disable all available outputs, awgs,
% demods, scopes,...
ziDisableEverything(device);

% Configure the device for this experiment.
ziDAQ('setInt', ['/' device '/sigins/' in_c '/imp50'], 0);
ziDAQ('setInt', ['/' device '/sigins/' in_c '/ac'], 1);
ziSiginAutorange(device, in_c); % Autorange channel
% ziDAQ('setInt', ['/' device '/sigins/' in_c '/autorange'], 1);
% ziDAQ('setDouble', ['/' device '/sigins/' in_c '/range'], 2.0*amplitude);
ziDAQ('setInt', ['/' device '/demods/*/order'], p.Results.filter_order);
ziDAQ('setDouble', ['/' device '/demods/' demod_c '/rate'], demod_rate);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/harmonic'], 1);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/enable'], 1);
ziDAQ('setInt', ['/' device '/demods/*/adcselect'], str2double(in_c));
ziDAQ('setDouble', ['/' device '/demods/*/timeconstant'], time_constant);
ziDAQ('setInt', ['/' device '/demods/1/adcselect'], str2double(extref_c));
ziDAQ('setInt', ['/' device '/extrefs/0/enable'], 1);
delay(1); % Wait for external reference to settle

%% Set up figure and start sweep loop
% Set up plot figure and meta data
[plotHandles,subPlotFigureHandle] = initializeSR830Meas1D(sweepType{1},doBackAndForth,1);

% Adjust for sign of sweep
step = checkDeltaSign(start,stop,step);
paramVector = start:step:stop;

if doBackAndForth
    flippedParam = fliplr(paramVector);
    paramVector = [paramVector flippedParam];
end

% Create arrays for data storage. 
[time,xs,ys,mags,xvals,avgxs,avgys,avgmags,stdxs,stdys,stdms] = deal([]);

% Halfway point in case back and forth is done.
halfway = length(paramVector)/2;
index = 1;
% time_index = 1;

settling_time = ziFO2ST(time_constant,p.Results.filter_order,'percent',99);

startTime = now;
poll_duration_samples = [];

% Main parameter loop
for value = paramVector

    % Unsubscribe all streaming data.
    ziDAQ('unsubscribe', '*');

%     sigDACRamp(device,port,value,5,1100);
    setVal(device_id, port, value); delay(1.1e-3); % 5x RC filter to gate
    delay(settling_time); % delay to get a settled lowpass filter

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
    poll_timeout = 1; % timeout in [ms]
    t0 = (now-startTime)*86400;
    data = ziDAQ('poll', poll_duration, poll_timeout);

    if ziCheckPathInData(data, ['/' device '/demods/' demod_c '/sample'])
        sample = data.(device).demods(demod_idx).sample;
        t1 = sample.timestamp(1);

        clockbase = double(ziDAQ('getInt', ['/' device '/clockbase']));
        t = (double(sample.timestamp) - double(t1))/clockbase + t0;
        poll_duration_samples(index) = t(end)-t(1);
%         fprintf('Poll returned %.3f seconds of data\n', poll_duration_samples(index));

        time = [time t];
        xs = [xs sample.x];
        ys = [ys sample.y];
        mag = sqrt(sample.x.^2 + sample.y.^2);
        mags = [mags mag];

        stdx = std(sample.x);
        stdy = std(sample.y);
        
        xvals(index) = value;
        avgxs(index) = mean(sample.x);
        avgys(index) = mean(sample.y);
        stdxs(index) = std(sample.x);
        stdys(index) = std(sample.y);
        avgmags(index) = mean(mag);
        stdms(index) = sqrt(stdx.^2+stdy.^2);
    
        updateTimePlots(plotHandles,time,xs,ys,mags);
    
        % Assign all the data properly depending on doing a back and forth scan
        updateAveragePlots(plotHandles,xvals,avgmags,avgxs,avgys,stdms,stdxs,stdys,doBackAndForth,index,halfway);
        drawnow;
        index = index + 1;
    else
        sample = [];
    end
end

% Set up metadata to be saved with figure
metadata_struct.time_constant = ziDAQ('getDouble', ['/' device '/demods/' demod_c '/timeconstant']); % time_constant;
metadata_struct.filter_order = p.Results.filter_order;
metadata_struct.demod_rate = ziDAQ('getDouble', ['/' device '/demods/' demod_c '/rate']); % demod_rate;
metadata_struct.poll_duration = poll_duration_samples;
% metadata_struct.length = length(sample.x);
metadata_struct.controlDAC = evalin('base','controlDAC.channelVoltages;');
metadata_struct.supplyDAC = evalin('base','supplyDAC.channelVoltages;');
subPlotFigureHandle.UserData = metadata_struct;

% Unsubscribe from all paths.
ziDAQ('unsubscribe', '*');

% Save data
if ~strcmp(sweepType,'PHAS') && ~strcmp(sweepType,'Vpp')
    saveData(subPlotFigureHandle, genSR830PlotName(sweepType{1}));
end
end

%% Functions for updating plot and setting errorbars
function updateTimePlots(plotHandles,time,x,y,mag)
    setPlotXYData(plotHandles{1},time,x);
    setPlotXYData(plotHandles{2},time,y);
    setPlotXYData(plotHandles{3},time,mag);
    axis tight;
end

function updateAveragePlots(plotHandles,xvals,avgmag,avgx,avgy,stdm,stdx,stdy,doBackAndForth,index,halfway)
    if doBackAndForth && index > halfway
        setErrorBarXYData(plotHandles{4},xvals(1:halfway),avgx(1:halfway),stdx(1:halfway));
        setErrorBarXYData(plotHandles{6},xvals(1:halfway),avgy(1:halfway),stdy(1:halfway));
        setErrorBarXYData(plotHandles{8},xvals(1:halfway),avgmag(1:halfway),stdm(1:halfway));

        setErrorBarXYData(plotHandles{5},xvals(halfway+1:end),avgx(halfway+1:end),stdx(halfway+1:end));
        setErrorBarXYData(plotHandles{7},xvals(halfway+1:end),avgy(halfway+1:end),stdy(halfway+1:end));
        setErrorBarXYData(plotHandles{9},xvals(halfway+1:end),avgmag(halfway+1:end),stdm(halfway+1:end));
    elseif doBackAndForth && index <= halfway
            setErrorBarXYData(plotHandles{4},xvals,avgx,stdx);
            setErrorBarXYData(plotHandles{6},xvals,avgy,stdy);
            setErrorBarXYData(plotHandles{8},xvals,avgmag,stdm);
    else
        setErrorBarXYData(plotHandles{4},xvals,avgx,stdx);
        setErrorBarXYData(plotHandles{5},xvals,avgy,stdy);
        setErrorBarXYData(plotHandles{6},xvals,avgmag,stdm);
    end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end