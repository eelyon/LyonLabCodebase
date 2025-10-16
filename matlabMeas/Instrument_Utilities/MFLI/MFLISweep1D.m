function [mag,phase,x,y,stdm,stdphase,stdx,stdy] = MFLISweep1D(sweepType, start, stop, step, mfli_id, device_id, port, doBackAndForth, varargin)
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
p.addParameter('filter_order', 4, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.010, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 1e3, @isnumeric);
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
ziDAQ('setInt', ['/' device '/sigins/' in_c '/imp50'], 1);
ziDAQ('setInt', ['/' device '/sigins/' in_c '/ac'], 0);
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
delay(1); % Wait for external reference to settle

%% Set up figure and start sweep loop
% Set up plot figure and meta data
[plotHandles,subPlotFigureHandle] = initializeATS9416Meas1D(sweepType{1},doBackAndForth);

% Adjust for sign of sweep
step = checkDeltaSign(start,stop,step);
paramVector = start:step:stop;

if doBackAndForth
    flippedParam = fliplr(paramVector);
    paramVector = [paramVector flippedParam];
end

% Create arrays for data storage. 
[xvals,mag,phase,x,y,stdm,stdphase,stdx,stdy] = deal([]);

% Halfway point in case back and forth is done.
halfway = length(paramVector)/2;
index = 1;

% Main parameter loop
for value = paramVector

    % Unsubscribe all streaming data.
    ziDAQ('unsubscribe', '*');

%     sigDACRamp(device,port,value,5,1100);
    setVal(device_id, port, value);
    pause(10*time_constant); % pause to get a settled lowpass filter

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
    poll_timeout = 10; % timeout in [ms]
    data = ziDAQ('poll', poll_duration, poll_timeout);
    
    if ziCheckPathInData(data, ['/' device '/demods/' demod_c '/sample'])
        sample = data.(device).demods(demod_idx).sample;
    else
        sample = [];
    end
    
    Xrms = mean(sample.x);
%     length(sample.x)
    Yrms = mean(sample.y);
    stdXrms = std(sample.x);
    stdYrms = std(sample.y);

    x(index) = Xrms;
    y(index) = Yrms;
    stdx(index) = stdXrms;
    stdy(index) = stdYrms;
    
    Rrms = sqrt(Xrms.^2+Yrms.^2); % Magnitude in rms
    phi = rad2deg(atan2(real(Yrms),real(Xrms))); % Phase in degrees
    stdRrms = sqrt(stdXrms.^2+stdYrms.^2); % Magnitude error in rms
    stdPhi = sqrt(1/(Xrms.^2+Yrms.^2).^2*(Yrms.^2*stdXrms.^2+Xrms.^2*stdYrms.^2)); % Phase error in degrees

    xvals(index) = value;
    mag(index) = Rrms;
    phase(index) = phi;
    stdm(index) = stdRrms;
    stdphase(index) = stdPhi;

    % Assign all the data properly depending on doing a back and forth scan
    updatePlots(plotHandles,xvals,mag,phase,x,y,stdm,stdphase,stdx,stdy,doBackAndForth,index,halfway);
    drawnow;
    index = index + 1;
    
    % Unsubscribe from all paths.
    ziDAQ('unsubscribe', '*');
end

% Set up metadata to be saved with figure
metadata_struct.time_constant = time_constant; % ziDAQ('getDouble', ['/' device '/demods/*/timeconstant']);
metadata_struct.filter_order = p.Results.filter_order;
metadata_struct.demod_rate = p.Results.demod_rate; % ziDAQ('getDouble', ['/' device '/demods/' demod_c '/rate']);
metadata_struct.poll_duration = poll_duration;
metadata_struct.length = length(sample.x);
metadata_struct.controlDAC = evalin('base','controlDAC.channelVoltages;');
metadata_struct.supplyDAC = evalin('base','supplyDAC.channelVoltages;');

subPlotFigureHandle.UserData = metadata_struct;

% Save data
if ~strcmp(sweepType,'PHAS') && ~strcmp(sweepType,'Vpp')
    saveData(subPlotFigureHandle, genSR830PlotName(sweepType{1}));
end
end

%% Function for updating plot and setting errorbars
function updatePlots(plotHandles,xvals,mag,phase,x,y,stdm,stdphase,stdx,stdy,doBackAndForth,index,halfway)
    if doBackAndForth && index <= halfway
        setErrorBarXYData(plotHandles{1},xvals,x,stdx);
        setErrorBarXYData(plotHandles{3},xvals,y,stdy);
        setErrorBarXYData(plotHandles{5},xvals,mag,stdm);
        setErrorBarXYData(plotHandles{7},xvals,phase,stdphase);
    elseif doBackAndForth && index > halfway
        setErrorBarXYData(plotHandles{1},xvals(1:halfway),x(1:halfway),stdx(1:halfway));
        setErrorBarXYData(plotHandles{3},xvals(1:halfway),y(1:halfway),stdy(1:halfway));
        setErrorBarXYData(plotHandles{5},xvals(1:halfway),mag(1:halfway),stdm(1:halfway));
        setErrorBarXYData(plotHandles{7},xvals(1:halfway),phase(1:halfway),stdphase(1:halfway));
    
        setErrorBarXYData(plotHandles{2},xvals(halfway+1:end),x(halfway+1:end),stdx(halfway+1:end));
        setErrorBarXYData(plotHandles{4},xvals(halfway+1:end),y(halfway+1:end),stdy(halfway+1:end));
        setErrorBarXYData(plotHandles{6},xvals(halfway+1:end),mag(halfway+1:end),stdm(halfway+1:end));
        setErrorBarXYData(plotHandles{8},xvals(halfway+1:end),phase(halfway+1:end),stdphase(halfway+1:end));
    else
        setErrorBarXYData(plotHandles{1},xvals,x,stdx);
        setErrorBarXYData(plotHandles{2},xvals,y,stdy);
        setErrorBarXYData(plotHandles{3},xvals,mag,stdm);
        setErrorBarXYData(plotHandles{4},xvals,phase,stdphase);
    end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end