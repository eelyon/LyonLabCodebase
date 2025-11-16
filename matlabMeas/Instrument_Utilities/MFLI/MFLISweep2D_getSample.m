function [] = MFLISweep2D_getSample(sweepTypes,starts,stops,steps,mfli_id,device_ids,ports,varargin)
%MFLISWEEP1D_GETSAMPLE Summary of this function goes here
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
% Input impedance
p.addParameter('imp50',0,@isnumeric)
% Input coupling
p.addParameter('ac',1,@isnumeric)
% Filter order
p.addParameter('filter_order', 2, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.10, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 1e3, @isnumeric);
p.parse(varargin{:});
time_constant = p.Results.time_constant;

% Define some other helper parameters.
demod_c = '0'; % Demod channel, 0-based indexing for paths on the device.
in_c = '0'; % signal input channel
extref_c = '8'; % external reference channel - 8 for Aux In 1

% Create a base configuration: Disable all available outputs, awgs,
% demods, scopes,...
ziDisableEverything(device);

% Configure the device for this experiment.
ziDAQ('setInt', ['/' device '/sigins/' in_c '/imp50'], p.Results.imp50);
ziDAQ('setInt', ['/' device '/sigins/' in_c '/ac'], p.Results.ac);
ziSiginAutorange(device, in_c); % Autorange channel
ziDAQ('setInt', ['/' device '/demods/*/order'], p.Results.filter_order);
ziDAQ('setDouble', ['/' device '/demods/' demod_c '/rate'], p.Results.demod_rate);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/harmonic'], 1);
ziDAQ('setInt', ['/' device '/demods/' demod_c '/enable'], 1);
ziDAQ('setInt', ['/' device '/demods/*/adcselect'], str2double(in_c));
ziDAQ('setDouble', ['/' device '/demods/*/timeconstant'], time_constant);
ziDAQ('setInt', ['/' device '/demods/1/adcselect'], str2double(extref_c));
ziDAQ('setInt', ['/' device '/extrefs/0/enable'], 1);

%% Set up figure and start sweep loop
% Set up plot figure and meta data
[plotHandles,subPlotFigureHandle] = initializeMFLIMeas2D(sweepTypes,starts,stops,steps);

[sweepType1, sweepType2] = sweepTypes{:};
[start1, start2] = starts{:};
[stop1, stop2] = stops{:};
[step1, step2] = steps{:};
[device1, device2] = device_ids{:};
[port1, port2] = ports{:};

% Adjust for sign of sweep
step1 = checkDeltaSign(start1,stop1,step1);
paramVector1 = start1:step1:stop1;

step2 = checkDeltaSign(start2,stop2,step2);
paramVector2 = start2:step2:stop2;

% Create arrays for data storage. 
% [xvals,mag,phase,x,y] = deal([]);

index1 = 1;
index2 = 1;

settling_time = ziFO2ST(time_constant,p.Results.filter_order,'percent',99);

% Main parameter loop
for value1 = paramVector1

    % Unsubscribe all streaming data.
    ziDAQ('unsubscribe', '*');

%     sigDACRamp(device,port,value,5,1100);
    setVal(device1, port1, value1); delay(1.1e-3);

    for value2 = paramVector2
        setVal(device2, port2, value2); delay(1.1e-3);
        delay(settling_time); % delay to get a settled lowpass filter
        
        % Perform a global synchronisation between the device and the data server:
        % Ensure that the settings have taken effect on the device before issuing the
        % ``poll`` command and clear the API's data buffers to remove any old
        % data. Note: ``sync`` must be issued after waiting for the demodulator filter
        % to settle above.
        ziDAQ('sync');
    
        % Get data from MFLI
        % Subscribe to the demodulator sample.
        sample = ziDAQ('getSample', ['/' device '/demods/' demod_c '/sample']);
    
%         xvals(index2) = value;
%         x(index2) = sample.x;
%         y(index2) = sample.y;
%         mag(index2) = sqrt(sample.x.^2 + sample.y.^2);
%         phase(index2) = rad2deg(atan2(real(sample.y),real(sample.x)));
    
        % Assign all the data to the figures
        plotHandles{1}.CData(index1,index2) = sample.x;
        plotHandles{2}.CData(index1,index2) = sample.y;
        plotHandles{3}.CData(index1,index2) = sqrt(sample.x.^2 + sample.y.^2);
        drawnow;
        index2 = index2 + 1;
    end
index1 = index1 + 1;
end

% Set up metadata to be saved with figure
metadata_struct.time_constant = ziDAQ('getDouble', ['/' device '/demods/' demod_c '/timeconstant']); % time_constant;
metadata_struct.filter_order = p.Results.filter_order;
metadata_struct.demod_rate = ziDAQ('getDouble', ['/' device '/demods/' demod_c '/rate']); % p.Results.demod_rate;
metadata_struct.length = length(sample.x);
metadata_struct.controlDAC = evalin('base','controlDAC.channelVoltages;');
metadata_struct.supplyDAC = evalin('base','supplyDAC.channelVoltages;');
subPlotFigureHandle.UserData = metadata_struct;

% Unsubscribe from all paths.
ziDAQ('unsubscribe', '*');

% Save data
saveData(subPlotFigureHandle, [genSR830PlotName(sweepType1), '-over-', genSR830PlotName(sweepType2)]);
end