% Parameters
Fs = 10e6;          % Sampling frequency (Hz)
T = postTriggerSamples/Fs; % 1;               % Duration of the signal (seconds)
t = 0:1/Fs:T-1/Fs;   % Time vector
length(t)
f_signal = 1e6;       % Frequency of the signal (Hz)
f_reference = 1e6;    % Frequency of the reference signal (Hz)
sqr_wave = false;
noise_level = 0.5;   % Amplitude of noise

signal = sqrt(2)*bufferVolts(1,:);

% Generate the signal and noise
% signal = sqrt(2)*square(2*pi*f_signal*t-pi/2) + noise_level*randn(size(t)); % Signal with noise

% Generate the reference signal (known frequency)
if sqr_wave == true
    reference_signal = sqrt(2)*square(2*pi*f_reference*t)-1i*sqrt(2)*square(2*pi*f_reference*t+pi/2);
else
    reference_signal = sqrt(2)*cos(2*pi*f_reference*t-pi)-1i*sqrt(2)*sin(2*pi*f_reference*t-pi);
end

% Perform FFT on the signal and reference signal
N = length(t);
f = (-N/2:N/2-1)*(Fs/N);  % Frequency vector
signal_fft = fftshift(fft(signal));  % FFT of the signal
reference_X_fft = fftshift(fft(real(reference_signal)));  % FFT of the reference signal
reference_Y_fft = fftshift(fft(imag(reference_signal)));  % FFT of the reference signal

% Multiply signal spectrum by the conjugate of the reference spectrum (for X and Y)
mixed_signal_X_fft = signal_fft .* reference_X_fft; % X component (in-phase) % conj()
mixed_signal_Y_fft = signal_fft .* reference_Y_fft; % Y component (pi/2 out-of-phase) % conj()

% RC Low-pass filter in frequency domain
stages = 3; % Stages of RC filter
fc = 100;  % Cutoff frequency of the RC filter (Hz)
tau = 1/(2*pi*fc);  % Time constant

% Calculate the transfer function of the RC filter in the frequency domain
H_rc = (1 ./ (1 + 1i * (f/Fs) * tau)).^stages;  % Frequency response of the RC filter

% Apply the RC filter to the X and Y components in the frequency domain
filtered_signal_X_fft = mixed_signal_X_fft .* H_rc;
filtered_signal_Y_fft = mixed_signal_Y_fft .* H_rc;

% Perform inverse FFT to return to the time domain
filtered_signal_X = real(ifft(ifftshift(filtered_signal_X_fft)))*pi/4;  % X component
filtered_signal_Y = real(ifft(ifftshift(filtered_signal_Y_fft)))*pi/4;  % Y component

% Normalize the filtered signal to account for the scaling from FFT/XFFT
filtered_signal_X = filtered_signal_X / N;  % Normalize the X component
filtered_signal_Y = filtered_signal_Y / N;  % Normalize the Y component

X = sqrt(mean(filtered_signal_X.^2));
Y = sqrt(mean(filtered_signal_Y.^2));
R_xy = sqrt(X.^2+Y.^2);
phi_xy = rad2deg(atan2(mean(filtered_signal_Y), mean(filtered_signal_X)));

R = sqrt(filtered_signal_X.^2 + filtered_signal_Y.^2);
phi = rad2deg(atan2(filtered_signal_Y, filtered_signal_X));

% Plot original signal, reference signal, X and Y quadratures
figure;
subplot(1,3,1);
plot(t(1:100), signal(1:100)/sqrt(2));
hold on
plot(t(1:100), imag(reference_signal(1:100)/sqrt(2)));
hold off
title('Signal and Reference Signal');
xlabel('Time [s]');
ylabel('Amplitude');
legend('V_s','V_r')

subplot(1,3,2);
plot(t(1:100), filtered_signal_X(1:100));
hold on
plot(t(1:100), filtered_signal_Y(1:100));
hold off
title('X and Y Components');
xlabel('Time [s]');
ylabel('Amplitude');
legend('X','Y')

subplot(1,3,3);
yyaxis left
plot(t(1:100), R(1:100));
ylabel('Amplitude');
hold on
yyaxis right
plot(t(1:100), phi(1:100));
hold off
title('X and Y Components');
xlabel('Time [s]');
ylabel('Phase');
legend('R','\phi')

% Amplitude and phase extraction from X and Y
amplitude = sqrt(mean(filtered_signal_X.^2 + filtered_signal_Y.^2)); % Mean amplitude
phase = atan2(mean(filtered_signal_Y), mean(filtered_signal_X)); % Phase (radians)

% Display extracted amplitude and phase
disp(['Extracted Amplitude (Vpeak): ', num2str(amplitude)]);
disp(['Extracted Phase (degrees): ', num2str(rad2deg(phase))]);

disp(['Extracted X: ', num2str(X)]);
disp(['Extracted Y: ', num2str(Y)]);
disp(['Extracted R: ', num2str(R_xy)]);
disp(['Extracted \phi: ', num2str(phi_xy)]);
