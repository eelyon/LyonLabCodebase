function [filtered_signal_X,filtered_signal_Y] = ATS9416GetXY(buffer, samplesPerSec, postTriggerSamples, f_signal, waveForm)
%ATS9416GETXY Summary of this function goes here
%   Detailed explanation goes here
% Parameters
T = postTriggerSamples/samplesPerSec;
t = 0:1/samplesPerSec:T-1/samplesPerSec; % Time vector

input_signal = buffer(1,:); % Input signal

% Generate the reference signal (known frequency)
if strcmp(waveForm,'square')
    reference_signal_X = square(2 * pi * f_signal * t + pi/3);
    reference_signal_Y = square(2 * pi * f_signal * t + pi/3 + pi/2);
elseif strcmp(waveForm,'sine')
    reference_signal_X = sin(2 * pi * f_signal * t + pi/3);
    reference_signal_Y = cos(2 * pi * f_signal * t + pi/3 + pi/2);
else
    fprintf('Enter the correct wave type!\n')
    return
end

% Multiply input signal with reference signal (demodulation)
demodulated_signal_X = input_signal .* reference_signal_X;
demodulated_signal_Y = input_signal .* reference_signal_Y;

% Butterworth filter to extract the DC component
filter_cutoff = 1e6;  % Cutoff frequency (Hz)
[b, a] = butter(8, filter_cutoff / (samplesPerSec / 2), 'low');
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
plot(t(1:256), demodulated_signal_X(1:256));
hold on
plot(t(1:256), demodulated_signal_Y(1:256));
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