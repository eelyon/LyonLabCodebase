%% Acquire data from ATS9416 board and average
tic
clear xaxis bufferVolts X Y Xerr Yerr

% Set parameters for acquisition
global samplesPerSec
f_signal = 102e3;
channelMask = CHANNEL_A; % Select channels to capture, not all combinations are allowed

% NPT parameters
postTriggerSamples = 1000064; % Has to be at least 256 and multiple of 128
recordsPerBuffer = 1; % Set for averaging
buffersPerAcquisition = 1; % Set number of buffers

% TS parameters
% acquisitionLength_sec = 0.01;
% samplesPerBufferPerChannel = 640000;

% Calibrate phase to get ref. signal's phase in sync with Agilent
% [clbrAmp,clbrPhase] = ATS9416ClbrPhase(boardHandle, samplesPerSec, channelMask, 'square', f_signal);
% display(clbrPhase);

[result,bufferVolts] = ATS9416AcquireData_NPT(boardHandle,postTriggerSamples,recordsPerBuffer,buffersPerAcquisition,channelMask);
% [result,bufferVolts] = ATS9416AcquireData_TS(boardHandle, samplesPerSec, acquisitionLength_sec, samplesPerBufferPerChannel, channelMask);
% [result, bufferVolts] = AlazarAcquireData_TS(boardHandle);
% xaxis = linspace(0, postTriggerSamples*recordsPerBuffer/samplesPerSec, length(bufferVolts(1,:)));

% figure()
% plot(xaxis,bufferVolts(1,:))
% plot(xaxis,bufferVolts(2,:))

stages = 4; % RC filter stages
tc = 0.1; % RC filter cut off frequency
% phase = -192.61; % Phase offset for square wave from Awg2ch_Houck
phase = -172; % deg phase offset for two channel AWG (square wave output)

[X,Y,Xerr,Yerr] = ATS9416GetXY(bufferVolts,samplesPerSec,postTriggerSamples,f_signal,phase*pi/180,stages,tc);
fprintf('X %f', X); fprintf(' +- %f Vrms\n', Xerr)
fprintf('Y %f', Y); fprintf(' +- %f Vrms\n', Yerr)
Rrms = sqrt(X.^2+Y.^2); fprintf('R %f Vrms\n', Rrms)
phi = rad2deg(atan2(real(Y),real(X))); fprintf('phi %f degrees\n', phi)
toc