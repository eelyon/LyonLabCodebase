function [filtered_X,filtered_Y] = ATS9416GetXY(buffer, samplesPerSec, postTriggerSamples, f_signal, waveForm, phase)
%ATS9416GETXY Summary of this function goes here
%   Detailed explanation goes here
% Parameters
T = postTriggerSamples/samplesPerSec; % Period
t = 0:1/samplesPerSec:T-1/samplesPerSec; % Time vector
N = length(t);
f = (-N/2:N/2-1)*(samplesPerSec/N);  % Frequency vector

input_signal = buffer; % Input signal

% Generate the reference signal (known frequency)
if strcmp(waveForm,'square')
    reference_signal_X = square(2 * pi * f_signal * t + phase);
    reference_signal_Y = square(2 * pi * f_signal * t + phase + pi/2);
elseif strcmp(waveForm,'sine')
    reference_signal_X = cos(2 * pi * f_signal * t + phase);
    reference_signal_Y = cos(2 * pi * f_signal * t + phase + pi/2);
else
    fprintf('Enter the correct wave form!\n')
    return
end

% % Multiply input signal with reference signal (demodulation)
% demodulated_signal_X = input_signal .* reference_signal_X;
% demodulated_signal_Y = input_signal .* reference_signal_Y;
% 
% % Butterworth filter to extract the DC component
% filter_cutoff = 1e6;  % Cutoff frequency (Hz)
% [b, a] = butter(8, filter_cutoff / (samplesPerSec / 2), 'low');
% filtered_X = filtfilt(b, a, demodulated_signal_X);
% filtered_Y = filtfilt(b, a, demodulated_signal_Y);

demod_X = input_signal .* reference_signal_X;
demod_Y = input_signal .* reference_signal_Y;

% Demodulation
demod_X_fft = fftshift(fft(demod_X)) / N; % In-phase demodulation
demod_Y_fft = fftshift(fft(demod_Y)) / N; % Quadrature demodulation

% RC filter transfer function
stages = 2;
fc = 10;
tau = 1 / fc;
H_rc = (1 ./ (1 + 1j * 2 * pi * f * tau)).^stages;

% Apply the RC filter in frequency domain
filtered_X_fft = demod_X_fft .* H_rc;
filtered_Y_fft = demod_Y_fft .* H_rc;

% Inverse Fourier Transform to get the filtered X and Y in time domain
filtered_X = ifft(ifftshift(filtered_X_fft))*N; % Normalize X
filtered_Y = ifft(ifftshift(filtered_Y_fft))*N; % Normalize Y

amplitude = sqrt(filtered_X.^2 + filtered_Y.^2);
phase = rad2deg(atan2(real(filtered_Y), real(filtered_X)));

% Plot results
figure;

subplot(4, 1, 1);
plot(t, input_signal);
hold on
plot(t, 0.3*reference_signal_X);
hold on
plot(t, 0.3*reference_signal_Y);
hold off
xlim([t(1), t(200)])
title('Input Signal (Square Wave + Noise)');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Sig.','RefX','RefY')

subplot(4, 1, 2);
plot(t, demod_X);
hold on
plot(t, demod_Y);
hold off
xlim([t(1), t(200)])
title('Demodulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
legend('DemodX','DemodY')

subplot(4, 1, 3);
plot(t, filtered_X);
hold on
plot(t, filtered_Y);
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

fprintf('The X mean is %f\n', mean(filtered_X))
fprintf('The X std is %f\n', std(filtered_X))
fprintf('The Y mean is %f\n', mean(filtered_Y))
fprintf('The Y std is %f\n', std(filtered_Y))