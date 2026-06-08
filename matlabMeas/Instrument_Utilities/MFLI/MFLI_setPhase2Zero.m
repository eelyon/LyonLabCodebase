function [] = MFLI_setPhase2Zero(mfli_id,startPhase,deltaPhase,stopPhase,varargin)
%MFLI_SETPHASE2ZERO Summary of this function goes here
%   Detailed explanation goes here

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

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% Filter order
p.addParameter('filter_order', 2, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.10, @isnumeric);
p.parse(varargin{:});
time_constant = p.Results.time_constant;

demod_c = '0'; % Demod channel, 0-based indexing for paths on the device.
% in_c = '0'; % signal input channel

ziDAQ('setInt', ['/' device '/demods/*/order'], p.Results.filter_order);
ziDAQ('setDouble', ['/' device '/demods/*/timeconstant'], time_constant);

[xvals,x,y,phase] = deal([]);
index = 1;

phase_array = startPhase:deltaPhase:stopPhase;

settling_time = ziFO2ST(time_constant,p.Results.filter_order,'percent',99);

fig = figure; clf;
tileFigures(fig,1,1,2,[],[0,0,0.7,0.5]);
for value = phase_array

    % Unsubscribe all streaming data.
    ziDAQ('unsubscribe', '*');

%     sigDACRamp(device,port,value,5,1100);
    ziDAQ('setDouble', ['/' device '/demods/0/phaseshift'],value);
%     setVal(device_id, port, value); delay(1.1e-3);
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

    xvals(index) = value;
    x(index) = sample.x;
    y(index) = sample.y;
    phase(index) = rad2deg(atan2(real(sample.y),real(sample.x)));

    % Assign all the data properly depending on doing a back and forth scan
%     updatePlots(plotHandles,xvals,mag,phase,x,y,doBackAndForth,index,halfway);
    subplot(1, 3, 1)
    plot(xvals, x, 'bo');
    xlabel("Phase [^{\circ}]");
    ylabel("X [V_{rms}]");
    title("X vs Voltage");
%     xlim([frequencies(1),frequencies(end)])

    subplot(1, 3, 2)
    plot(xvals, y, 'ro');
    xlabel("Phase [^{\circ}]");
    ylabel("Y [V_{rms}]");
    title("Y vs Voltage");
%     xlim([frequencies(1),frequencies(end)])

    subplot(1, 3, 3)
    plot(xvals, phase, 'ko');
    xlabel("Phaseshift [^{\circ}]");
    ylabel("Phase [^{\circ}]");
    title("Phase vs Voltage");

    drawnow;
    index = index + 1;
end

abs_phases = abs(phase);
minValPhase = xvals(find(abs_phases==min(abs_phases)));
fprintf('Min. phase setting at %f\n', minValPhase);
ziDAQ('setDouble', ['/' device '/demods/0/phaseshift'],minValPhase);
end