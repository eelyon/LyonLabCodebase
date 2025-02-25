%% Acquire data from ATS9416 board and average
clear bufferVolts

% Set parameters for acquisition
f_signal = 1e6;
channelMask = CHANNEL_B; % Select channels to capture, not all combinations are allowed

% NPT parameters
postTriggerSamples = 1000064; % Has to be at least 256 and multiple of 128
recordsPerBuffer = 1; % Set for averaging
buffersPerAcquisition = 1; % Set number of buffers

% TS parameters
% acquisitionLength_sec = 0.01;
% samplesPerBufferPerChannel = 640000;

[result,bufferVolts] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, recordsPerBuffer, buffersPerAcquisition, channelMask);
% [result,bufferVolts] = ATS9416AcquireData_TS(boardHandle, samplesPerSec, acquisitionLength_sec, samplesPerBufferPerChannel, channelMask);
% [result, bufferVolts] = AlazarAcquireData_TS(boardHandle);

% figure()
% plot(xaxis,bufferVolts(1,:))
% plot(xaxis,bufferVolts(2,:))

phase_2chAwgHouck = 140*pi/180; %150*pi/180;
phase_1chAwg = 140*pi/180; %-90*pi/180; %60*pi/180;

[X,Y] = ATS9416GetXY(bufferVolts, samplesPerSec, postTriggerSamples, f_signal, 'square', 2.38+pi);
% Xrms = sqrt(mean(X.^2))
% Yrms = sqrt(mean(Y.^2))
% R = mean(sqrt(X.^2+Y.^2)) %sqrt(Xrms.^2+Yrms.^2)
% phi = rad2deg(atan2(real(Yrms),real(Xrms)))