% Parameters
Fs = 10000;          % Sampling frequency (Hz)
T = 1;               % Duration of the signal (seconds)
t = 0:1/Fs:T-1/Fs;   % Time vector
f_signal = 50;       % Frequency of the signal (Hz)
f_reference = 50;    % Frequency of the reference signal (Hz)
noise_level = 0.5;   % Amplitude of noise

% Generate the signal and noise
signal = sin(2*pi*f_signal*t) + noise_level*randn(size(t)); % Signal with noise

% Generate the reference signal (known frequency)
reference_signal = sin(2*pi*f_reference*t);

% Plot original signal and reference signal
figure;
subplot(2,1,1);
plot(t, signal);
title('Signal with Noise');
xlabel('Time [s]');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, reference_signal);
title('Reference Signal');
xlabel('Time [s]');
ylabel('Amplitude');

% Perform FFT on the signal and reference signal
N = length(t);
f = (-N/2:N/2-1)*(Fs/N);  % Frequency vector
signal_fft = fftshift(fft(signal));  % FFT of the signal
reference_fft = fftshift(fft(reference_signal));  % FFT of the reference signal

% Multiply signal spectrum by the conjugate of the reference spectrum (mixing)
mixed_signal_fft = signal_fft .* conj(reference_fft);

% RC Low-pass filter in frequency domain
cutoff_freq = 100;  % Cutoff frequency of the RC filter (Hz)
tau = 1/(2*pi*cutoff_freq);  % Time constant (tau = 1/(2*pi*f_c))

% Calculate the transfer function of the RC filter in the frequency domain
H_rc = 1 ./ (1 + 1i * (f/Fs) * tau);  % Frequency response of the RC filter

% Apply the RC filter to the mixed signal in the frequency domain
filtered_signal_fft = mixed_signal_fft .* H_rc;

% Perform inverse FFT to return to the time domain
filtered_signal = real(ifft(ifftshift(filtered_signal_fft)));  % IFFT of the filtered signal

% Normalize the filtered signal to account for the scaling from FFT/IFFT
filtered_signal = filtered_signal / N;  % Normalize the result by the number of samples

% Amplitude and phase extraction
amplitude = rms(filtered_signal); % Root mean square (rms) value for amplitude
phase = atan2(sum(filtered_signal .* cos(2*pi*f_reference*t)), sum(filtered_signal .* sin(2*pi*f_reference*t))); % Phase

% Plot the filtered signal
figure;
plot(t, filtered_signal);
title('Filtered Signal with RC Low-pass Filter in Frequency Domain');
xlabel('Time [s]');
ylabel('Amplitude');

% Display extracted amplitude and phase
disp(['Extracted Amplitude: ', num2str(amplitude)]);
disp(['Extracted Phase (radians): ', num2str(phase)]);
