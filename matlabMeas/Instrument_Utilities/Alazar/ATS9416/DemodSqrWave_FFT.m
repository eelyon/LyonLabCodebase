% Parameters
fs = 1e4;               % Sampling frequency (Hz)
t = 0:1/fs:1;           % Time vector (1 second)
signal_freq = 50;       % Frequency of input signal (Hz)
reference_freq = 50;    % Reference frequency (Hz)
noise_amplitude = 1;    % Noise amplitude
signal_amplitude = 1;   % Signal amplitude
tau = 0.01;             % RC time constant (seconds)

% Generate input signal (square wave + noise)
signal = signal_amplitude * square(2 * pi * signal_freq * t);
noise = noise_amplitude * randn(size(t));
input_signal = signal + noise;

% Generate sine and cosine reference signals
reference_cos = cos(2 * pi * reference_freq * t); % In-phase
reference_sin = sin(2 * pi * reference_freq * t); % Quadrature

% Fourier Transform of input and reference signals
N = length(t); % Number of samples
input_fft = fft(input_signal);
reference_cos_fft = fftshift(fft(reference_cos));
reference_sin_fft = fftshift(fft(reference_sin));

% Frequency vector
f = (-N/2:N/2-1)*(Fs/N);  % Frequency vector

% Demodulation in frequency domain
demod_cos_fft = input_fft .* conj(reference_cos_fft); % In-phase demodulation
demod_sin_fft = input_fft .* conj(reference_sin_fft); % Quadrature demodulation

% RC filter transfer function
H_rc = 1 ./ (1 + 1j * 2 * pi * f * tau);

% Apply the RC filter in frequency domain
filtered_cos_fft = demod_cos_fft .* H_rc;
filtered_sin_fft = demod_sin_fft .* H_rc;

% Inverse Fourier Transform to get the filtered X and Y in time domain
X = real(ifft(ifftshift(filtered_cos_fft))) / N; % Normalize X
Y = real(ifft(ifftshift(filtered_sin_fft))) / N; % Normalize Y

% Calculate the amplitude and phase
amplitude = sqrt(X.^2 + Y.^2); % Signal amplitude
phase = atan2(Y, X);           % Signal phase (radians)

% Plot results
figure;

subplot(5, 1, 1);
plot(t, input_signal);
title('Input Signal (Square Wave + Noise)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(5, 1, 2);
plot(t, X);
title('In-Phase Component (X)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(5, 1, 3);
plot(t, Y);
title('Quadrature Component (Y)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(5, 1, 4);
plot(t, phase);
title('Signal Phase');
xlabel('Time (s)');
ylabel('Phase (radians)');

subplot(5, 1, 5);
plot(t, amplitude);
title('Signal Amplitude');
xlabel('Time (s)');
ylabel('Amplitude');