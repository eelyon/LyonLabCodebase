% Parameters
Fs = 100e6; % Sampling frequency (Hz)
postTriggerSamples = 1000;
T = postTriggerSamples/Fs; % Duration of the signal (seconds)
t = 0:1/Fs:T-1/Fs; % Time vector
f_signal = 1e6; % Frequency of the signal (Hz)
signal_amplitude = 1;
noise_level = 0.1; % Amplitude of noise

y = signal_amplitude * cos(2 * pi * f_signal * t + 23*pi/180) + noise_level * randn(size(t));
yf = lowpass(y, 1e6, Fs);

amp = (max(yf) - min(yf))/2;
phase = 20;
dcOffset = mean(yf);
 
fit = @(b,t)  b(1).*(cos(2*pi*t*f_signal + b(2)*pi/180)) + b(3); % Function to fit
fcn = @(b) sum((fit(b,t) - yf).^2); % Least-Squares cost function
s = fminsearch(fcn, [amp; phase; dcOffset]) % Minimise Least-Squares

figure
plot(t,y)
hold on
plot(t,fit(s,t))
hold off
legend('signal','fit')