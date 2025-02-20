function [clbrAmp,clbrPhase] = ATS9416CalbrPhase(boardHandle, samplesPerSec, channel, waveForm, f_signal)
%ATS9416CALBRPHASE Fit cosine to AWG signal measured with Alazar
%   Detailed explanation goes here

% Parameters
postTriggerSamples = 1280000;
T = postTriggerSamples/samplesPerSec; % Duration of the signal (seconds)
t = 0:1/samplesPerSec:T-1/samplesPerSec; % Time vector
t = t(1:200);

[~,y] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, 1, 1, channel);
yf = y; %lowpass(y, f_signal, samplesPerSec); % Filter measured signal

% TODO - Adjust the phase fit parameter if needed
amp = (max(yf) - min(yf))/2;
phase = 3;
dcOffset = mean(yf);
 
% Generate the reference signal (known frequency)
if strcmp(waveForm,'square')
    fit = @(b,t)  b(1).*(square(2*pi*t*f_signal + b(2))) + b(3); % Function to fit
elseif strcmp(waveForm,'sine')
    fit = @(b,t)  b(1).*(cos(2*pi*t*f_signal + b(2))) + b(3); % Function to fit
else
    fprintf('Enter the correct wave form!\n')
    return
end

fcn = @(b) sum((fit(b,t) - yf(1:200)).^2); % Least-Squares cost function
s = fminsearch(fcn, [amp; phase; dcOffset]); % Minimise Least-Squares

clbrAmp = s(1);
clbrPhase = round(s(2),2);
fprintf('-> The amplitude is %.4f V and the phase is %.2f (actual %.4f) radians\n', clbrAmp, clbrPhase, s(2))

plotFit = fit(s,t);

figure
plot(t, y(1:200))
hold on
plot(t, plotFit)
hold off
xlim([t(1), t(200)])
title('Amplitude and Phase Calibration')
xlabel('Time  (sec)')
ylabel('Amplitude (V)')
legend('AWG Signal', 'Fit')

clear y plotFit
end