%% This script measures measures a sine from the Agilent at 100MSa/sec
%% and fits a sine to it to obtain amplitude, phase, and offset
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
f_signal = 1e6; % Frequency of the signal (Hz)
signal_amplitude = 1;
noise_level = 0.1;

[result,y] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, 1, 1, CHANNEL_B);

% y = signal_amplitude * cos(2 * pi * f_signal * t + 23*pi/180) + noise_level * randn(size(t));
yf = lowpass(y, 1e6, samplesPerSec);

amp = (max(yf) - min(yf))/2;
phase = 20;
dcOffset = mean(yf);
 
fit = @(b,t)  b(1).*(square(2*pi*t*f_signal + b(2))) + b(3)); % Function to fit
fcn = @(b) sum((fit(b,t) - yf).^2); % Least-Squares cost function
s = fminsearch(fcn, [amp; phase; dcOffset]) % Minimise Least-Squares
% calbrAmp = s(1)
% calbrPhase = round(s(2))

plotFit = fit(s,t);

figure
plot(t, y)
hold on
plot(t, plotFit)
hold off
xlim(t(1), t(1000))
legend('signal','fit')