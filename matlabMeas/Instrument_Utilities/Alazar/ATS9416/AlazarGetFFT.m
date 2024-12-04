Fs = 10e6; % Sampling frequency
Ts = 1/Fs; % Time increment
NSD = false; % Noise Spectral Density

yDat = bufferVolts(1,:); % Data
L = length(yDat); % Data length

y = fft(yDat);
f = (0:(L/2)) * Fs/L; % FFT frequency

figure
if NSD == true
    P2 = abs(y)*1/(sqrt(Fs)*L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1); % (1) and (end) correspond to zero and Nyquist frequencies
    plot(f,P1)
    xlabel('Frequency (Hz)')
    ylabel('NSD (V/\surd{Hz})')
else
    P2 = abs(y)*1/L;
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1); % (1) and (end) correspond to zero and Nyquist frequencies
    plot(f,P1)
    xlabel('Frequency (Hz)')
    ylabel('V')
end