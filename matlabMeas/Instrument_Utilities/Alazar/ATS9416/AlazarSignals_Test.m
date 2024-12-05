% Parameters
Fs = 100;          % Sampling frequency (Hz)
T = 100/Fs; % 1;               % Duration of the signal (seconds)
t = 0:1/Fs:T-1/Fs;   % Time vector
length(t)
f_signal = 10;       % Frequency of the signal (Hz)
f_reference = 10;    % Frequency of the reference signal (Hz)
sqr_wave = false;
noise_level = 0;   % Amplitude of noise
phase_shift = -pi/2;

signal = sin(2*pi*f_signal*t) + noise_level*randn(size(t));
reference = cos(2*pi*f_signal*t).*exp(1j*phase_shift);

figure
plot(t,signal)
hold on
plot(t,reference)
hold off
legend('signal','reference')