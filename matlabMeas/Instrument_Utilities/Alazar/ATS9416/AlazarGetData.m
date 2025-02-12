%% Acquire data from ATS9416 board and average
clear xaxis bufferVolts X Y

% Set parameters for acquisition
f_signal = 10e3;
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
xaxis = linspace(0, postTriggerSamples/samplesPerSec, length(bufferVolts(1,:)));

figure()
plot(xaxis,bufferVolts(1,:))
% plot(xaxis,bufferVolts(2,:))

% phase_2chAwgHouck = 140*pi/180; %150*pi/180;
% phase_1chAwg = 140*pi/180; %-90*pi/180; %60*pi/180;

[X,Y] = ATS9416GetXY(bufferVolts, samplesPerSec, postTriggerSamples, f_signal, 'square', clbrPhase); % 2.38+pi
Xrms = sqrt(mean(X.^2))*1/sqrt(2); fprintf('Xrms %f\n', Xrms)
Yrms = sqrt(mean(Y.^2))*1/sqrt(2); fprintf('Yrms %f\n', Yrms)
R = mean(sqrt(X.^2+Y.^2)); fprintf('R (Vpeak) %f\n', R)
Rrms = sqrt(Xrms.^2+Yrms.^2); fprintf('Rrms %f\n', Rrms)
XYabsSum = mean(abs(X)+abs(Y)); fprintf('mean(abs(x)+abs(Y)) %f\n', XYabsSum)
phi = rad2deg(atan2(real(Yrms),real(Xrms))); fprintf('phi %f\n', phi)