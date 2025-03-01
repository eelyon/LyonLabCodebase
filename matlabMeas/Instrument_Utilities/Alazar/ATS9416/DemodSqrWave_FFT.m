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

% Generate input signal (square wave + noise)
signal = signal_amplitude * square(2 * pi * f_signal * t + phase*pi/180) + noise_level * randn(size(t));
% signal = sign(cos(2 * pi * f_signal * t + 0*pi/180)) + noise_level * randn(size(t));

% Generate sine and cosine reference signals
reference_X = square(2 * pi * f_signal * t); % In-phase
reference_Y = square(2 * pi * f_signal * t + pi/2); % Quadrature

% Fourier Transform of input and reference signals
input_fft = fftshift(fft(signal));
reference_X_fft = fftshift(fft(reference_X));
reference_Y_fft = fftshift(fft(reference_Y));

% Demodulation
demod_X = signal .* reference_X;
demod_Y = signal .* reference_Y;
demod_X_fft = fftshift(fft(demod_X)) / N; % In-phase demodulation
demod_Y_fft = fftshift(fft(demod_Y)) / N; % Quadrature demodulation

% RC filter transfer function
stages = 2;
fc = 10;
tau = 1 / fc;
H_rc = (1 ./ (1 + 1j * 2 * pi * f * tau)).^stages;

% Simple rejecting filter mask
% Fc = 10; % Cut-off frequency
% filterMask = (abs(f) <= Fc) | (abs(f) >= Fs - Fc);
% signal_filterMask_fft = (fftshift(fft(signal))) .* filterMask;

% Apply the RC filter in frequency domain
filtered_X_fft = demod_X_fft .* H_rc;
filtered_Y_fft = demod_Y_fft .* H_rc;

% Inverse Fourier Transform to get the filtered X and Y in time domain
X = ifft(ifftshift(filtered_X_fft))*N; % Normalize X
Y = ifft(ifftshift(filtered_Y_fft))*N; % Normalize Y

% Calculate the amplitude and phase
amplitude = sqrt(X.^2 + Y.^2); % Signal amplitude
meanR = mean(amplitude)
phase = atan2(real(Y), real(X)); % Signal phase (radians)
meanPhi = mean(rad2deg(phase))

plotData = fftshift(fft(signal))/N;

% Plot results
figure;
subplot(4, 1, 1);
plot(t(1:200), signal(1:200));
hold on
plot(t(1:200), reference_X(1:200))
hold on
plot(t(1:200), reference_Y(1:200))
hold off
title('Input Signal and Ref. Signal');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Sig.','Ref. X','Ref. Y')

subplot(4, 1, 2);
plot(t(1:100), demod_X(1:100));
hold on
plot(t(1:100), demod_Y(1:100));
hold off
xlabel('Time (s)');
ylabel('Amplitude');
legend('Demod. X','Demod. Y')

subplot(4, 1, 3);
plot(demod_Y, demod_X)
legend('X vs. Y')

subplot(4, 1, 4);
plot(t, real(X))
hold on
plot(t, real(Y))
hold off
xlabel('Time (s)');
ylabel('Amplitude');
legend('Filtered X','Filtered Y')

% figure
% 
% subplot(2, 1, 1);
% plot(t, rad2deg(phase));
% title('Signal Phase');
% xlabel('Time (s)');
% ylabel('Phase (degrees)');
% 
% subplot(2, 1, 2);
% plot(t, amplitude);
% title('Signal Amplitude');
% xlabel('Time (s)');
% ylabel('Amplitude');

function H_rc = lowPass(fc, stages, f)
    tau = 1 / fc;
    H_rc = (1 ./ (1 + 1j * 2 * pi * f * tau)).^stages;
end

function H_rc = highPass(fc, stages, f)
    tau = 1 / fc;
    H_rc = ((1j * 2 * pi * f * tau) ./ (1 + 1j * 2 * pi * f * tau)).^stages;
end