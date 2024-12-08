%% Acquire data from ATS9416 board and average
% Set parameters for acquisition
f_signal = 1e6;
postTriggerSamples = 1280000; % Has to be at least 256 and multiple of 128
recordsPerBuffer = 1; % Set for averaging
buffersPerAcquisition = 1; % Set number of buffers
channelMask = CHANNEL_A; % Select channels to capture, not all combinations are allowed

[result,bufferVolts] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, recordsPerBuffer, buffersPerAcquisition, channelMask);

% figure()
% plot(xaxis,bufferVolts(1,:))
% plot(xaxis,bufferVolts(2,:))

[X,Y] = ATS9416GetXY(bufferVolts, samplesPerSec, postTriggerSamples, f_signal, 'square');
Xrms = sqrt(mean(X.^2))
Yrms = sqrt(mean(Y.^2))
R = sqrt(Xrms.^2+Yrms.^2)
phi = rad2deg(atan2(Yrms,Xrms))