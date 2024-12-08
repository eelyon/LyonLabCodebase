% Parameters
fs = samplesPerSec;               % Sampling frequency (Hz)
T = postTriggerSamples/samplesPerSec;
t = 0:1/fs:T-1/fs;           % Time vector (1 second)
signal_freq = 1e6;       % Frequency of input signal (Hz)
reference_freq = 1e6;    % Reference frequency (Hz)
noise_amplitude = 1;    % Noise amplitude
signal_amplitude = 1;   % Signal amplitude

% Generate input signal (square wave + noise)
input_signal = signal_amplitude * square(2 * pi * signal_freq * t) + noise_amplitude * randn(size(t));
% input_signal = bufferVolts(1,:);

% Generate square wave reference signal
reference_signal_X = square(2 * pi * reference_freq * t + pi/3);
reference_signal_Y = square(2 * pi * reference_freq * t + pi/3 + pi/2);

% Multiply input signal with reference signal (demodulation)
demodulated_signal_X = input_signal .* reference_signal_X;
demodulated_signal_Y = input_signal .* reference_signal_Y;

% Low-pass filter to extract the DC component
filter_cutoff = 1e6;  % Cutoff frequency (Hz)
[b, a] = butter(8, filter_cutoff / (fs / 2), 'low');  % Butterworth filter
filtered_signal_X = filtfilt(b, a, demodulated_signal_X);
filtered_signal_Y = filtfilt(b, a, demodulated_signal_Y);

amplitude = sqrt(filtered_signal_X.^2 + filtered_signal_Y.^2);
phase = rad2deg(atan2(filtered_signal_Y, filtered_signal_X));

% Plot results
figure;

subplot(4, 1, 1);
plot(t(1:256), input_signal(1:256));
hold on
plot(t(1:256), reference_signal_X(1:256));
hold on
plot(t(1:256), reference_signal_Y(1:256));
hold off
title('Input Signal (Square Wave + Noise)');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Sig.','RefX','RefY')

subplot(4, 1, 2);
plot(t, demodulated_signal_X);
hold on
plot(t, demodulated_signal_Y);
hold off
title('Demodulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
legend('DemodX','DemodY')

subplot(4, 1, 3);
plot(t, filtered_signal_X);
hold on
plot(t, filtered_signal_Y);
hold off
title('Filtered Signal (Lock-In Output)');
xlabel('Time (s)');
ylabel('Amplitude');
legend('FilX','FilY')

subplot(4, 1, 4);
yyaxis left
plot(t, amplitude);
ylabel('Amplitude');
hold on
yyaxis right
plot(t, phase);
ylabel('Phase')
hold off
title('Amp. and Phase');
xlabel('Time (s)');
legend('Amp.','Phase')

fprintf('The X mean is %f\n', mean(filtered_signal_X))
fprintf('The X std is %f\n', std(filtered_signal_X))
fprintf('The Y mean is %f\n', mean(filtered_signal_Y))
fprintf('The Y std is %f\n', std(filtered_signal_Y))

% Compute the FFT of the filtered signal to see frequency content
% figure;
% N = length(filtered_signal);
% f = (0:N-1)*(Fs/N);  % Frequency vector
% Y = fft(filtered_signal);  % FFT of the filtered signal
% plot(f(1:N/2), abs(Y(1:N/2)));
% title('Frequency Spectrum of the Output');
% xlabel('Frequency [Hz]');
% ylabel('Amplitude');
