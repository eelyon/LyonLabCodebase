function [clbrAmp,clbrPhase] = ATS9416CalbrPhase(boardHandle, f_signal, channel)
%ATS9416CALBRPHASE Fit cosine to AWG signal measured with Alazar
%   Detailed explanation goes here

% Configure the board's sample rate
samplesPerSec = 100e6;
if ~ATS9416ConfigureBoard(boardHandle,samplesPerSec)
  fprintf('Error: Board configuration failed\n');
  return
end

% Parameters
postTriggerSamples = 1280000;
T = postTriggerSamples/samplesPerSec; % Duration of the signal (seconds)
t = 0:1/samplesPerSec:T-1/samplesPerSec; % Time vector

[~,y] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, 1, 1, channel);
yf = lowpass(y, f_signal, samplesPerSec); % Filter measured signal

amp = (max(yf) - min(yf))/2;
phase = 60;
dcOffset = mean(yf);
 
fit = @(b,t)  b(1).*(cos(2*pi*t*f_signal + b(2))) + b(3); % Function to fit
fcn = @(b) sum((fit(b,t) - yf).^2); % Least-Squares cost function
s = fminsearch(fcn, [amp; phase; dcOffset]); % Minimise Least-Squares

clbrAmp = s(1);
clbrPhase = round(s(2),1);
fprintf('-> The amplitude is %.4f V and the phase is %.1f (actual %.4f) radians\n', clbrAmp, clbrPhase, s(2))

plotFit = fit(s,t);

figure
plot(t, y)
hold on
plot(t, plotFit)
hold off
xlim([t(1), t(1000)])
title('Amplitude and Phase Calibration')
xlabel('Time  (sec)')
ylabel('Amplitude (V)')
legend('AWG Signal', 'Fit')
end

