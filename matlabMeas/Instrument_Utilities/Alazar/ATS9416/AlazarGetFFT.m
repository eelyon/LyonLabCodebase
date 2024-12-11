[result,bufferVolts] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, recordsPerBuffer, buffersPerAcquisition, channelMask);

Fs = 20e6; % Sampling frequency
Ts = 1/Fs; % Time increment
PSD = false; % Power Spectral Density
spectrumVolts = true; % Spectrum in volts
gainAmp = 32*200;

yDat = bufferVolts; % Data
L = length(yDat); % Data length

y = fft(yDat);
f = (0:(L/2)) * Fs/L; % FFT frequency

figure
if PSD == true
    P2 = abs(y)*1/(sqrt(Fs)*L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1); % (1) and (end) correspond to zero and Nyquist frequencies
    loglog(f,P1/gainAmp)
    xlabel('Frequency (Hz)')
    ylabel('PSD (V/\surd{Hz})')
elseif spectrumVolts == true
    P2 = abs(y)*1/L;
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1); % (1) and (end) correspond to zero and Nyquist frequencies
    loglog(f,P1/gainAmp)
    xlabel('Frequency (Hz)')
    ylabel('V')
else
    P2 = abs(y)*1/L;
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1); % (1) and (end) correspond to zero and Nyquist frequencies
    plot(f,P1/gainAmp)
    xlabel('Frequency (Hz)')
    ylabel('V')
end