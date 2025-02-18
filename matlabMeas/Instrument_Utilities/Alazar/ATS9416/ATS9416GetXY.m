function [Xrms,Yrms,stdXrms,stdYrms] = ATS9416GetXY(buffer,samplesPerSec,postTriggerSamples,f_signal,phase,stages,fc,opt)
%ATS9416GETXY Summary of this function goes here
%   Detailed explanation goes here

% Parameters
T = postTriggerSamples/samplesPerSec; % Period
t = 0:1/samplesPerSec:T-1/samplesPerSec; % Time vector
N = length(t); % Number of samples
f = (-N/2:N/2-1)*(samplesPerSec/N); % Frequency vector for filter

% Generate the reference signal (known frequency)
reference_signal_X = cos(2 * pi * f_signal * t + phase);
reference_signal_Y = cos(2 * pi * f_signal * t + phase + pi/2);

% Demodulation
demod_X = buffer .* reference_signal_X; % In-phase demodulation
demod_Y = buffer .* reference_signal_Y; % Quadrature demodulation
demod_X_fft = fftshift(fft(demod_X)) / N;
demod_Y_fft = fftshift(fft(demod_Y)) / N;

% RC filter transfer function
H_rc = (1 ./ (1 + 1j * 2 * pi * (f/fc))).^stages;

% Apply the RC filter in frequency domain
filtered_X_fft = demod_X_fft .* H_rc;
filtered_Y_fft = demod_Y_fft .* H_rc;

% Inverse Fourier Transform to get filtered X and Y in time domain
filtered_X = ifft(ifftshift(filtered_X_fft))*N; % Normalize X
filtered_Y = ifft(ifftshift(filtered_Y_fft))*N; % Normalize Y

if exist('opt','var') % Normalise by 1.273 (amp. of 1st harmonic)
    Xrms = mean(real(filtered_X))*2/sqrt(2) / 1.273;
    Yrms = mean(real(filtered_Y))*2/sqrt(2) / 1.273;
    stdXrms = std(filtered_X)*2/sqrt(2) / 1.273;
    stdYrms = std(filtered_Y)*2/sqrt(2) / 1.273;
else
    Xrms = mean(real(filtered_X))*2/sqrt(2);
    Yrms = mean(real(filtered_Y))*2/sqrt(2);
    stdXrms = std(filtered_X)*2/sqrt(2);
    stdYrms = std(filtered_Y)*2/sqrt(2);
end

clear t f bufferVolts demod_X demod_Y demod_X_fft demod_Y_fft filtered_X_fft filtered_Y_fft amplitude phase filtered_X filtered_Y

end