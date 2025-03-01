function [avgRs,avgXs,avgYs,stdRs,stdXs,stdYs] = sweep1DMeasATS9416(start,stop,deltaParam,timeBetweenPoints,device,ports,doBackAndForth)
%SWEEP1DATS9416 Summary of this function goes here
%   Detailed explanation goes here

% Just for sign of sweep
deltaParam = checkDeltaSign(start,stop,deltaParam);
if doBackAndForth
    flippedParam = fliplr(paramVector);
    paramvector = [paramVector flippedParam];
end

%% Create all arrays for data storage. 
[avgRs,avgXs,avgYs,stdRs,stdXs,stdYs] = deal([]);

%% Halfway point in case back and forth is done.
halfway = length(paramVector)/2;

%% Set up loop that sweeps the device (i.e. DAC) port and gets data from Alazar
% Save data from Alazar in above array
% If the occasional (1/5) phase slip is fixed, then I don't need to average
% again but can simply increase samplesPerRecord for more points

%% Acquire data from ATS9416 board and average
% Set parameters for acquisition
f_signal = 1e6;
postTriggerSamples = 1280000; % Has to be at least 256 and multiple of 128
recordsPerBuffer = 1; % Set for averaging
buffersPerAcquisition = 1; % Set number of buffers
channelMask = CHANNEL_A; % Select channels to capture, not all combinations are allowed

[~,bufferVolts] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, recordsPerBuffer, buffersPerAcquisition, channelMask);
[X,Y] = ATS9416GetXY(bufferVolts, samplesPerSec, postTriggerSamples, f_signal, 'square');

avgX = mean(X);
avgY = mean(Y);
avgR = sqrt(avgX.^2 + avgY.^2);
avgPhi = rad2deg(atan2(avgY,avgX));

stdX = std(X);
stdY = std(Y);
stdR = sqrt(stdX.^2 + stdY.^2);
stdPhi = rad2deg(atan2(stdY,stdX));

refreshdata;
drawnow;

% figure()
% plot(xaxis,bufferVolts(1,:))
% plot(xaxis,bufferVolts(2,:))

end

