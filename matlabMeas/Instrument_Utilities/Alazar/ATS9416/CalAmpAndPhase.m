% Parameters
Fs = 100e6;          % Sampling frequency (Hz)
postTriggerSamples = 100000;
T = postTriggerSamples/Fs; % 1;               % Duration of the signal (seconds)
t = 0:1/Fs:T-1/Fs;   % Time vector
N = length(t);
f = (-N/2:N/2-1)*(Fs/N);  % Frequency vector
f_signal = 1e6;       % Frequency of the signal (Hz)
signal_amplitude = 1;
noise_level = 0;   % Amplitude of noise

signal = signal_amplitude * cos(2 * pi * f_signal * t + 45*pi/180) + noise_level * randn(size(t));
sinFit = fit(t, signal, 'sin1')

figure
plot(t(1:100),signal(1:100))
hold on
plot(t(1:100),sinFit(1:100))
hold off