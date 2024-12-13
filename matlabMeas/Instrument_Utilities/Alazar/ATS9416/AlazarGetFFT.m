samplesPerSec = 10e6; % Sampling rate -> FFT freq.
postTriggerSamples = 1000064; % Samples -> FFT resolution
average = 1; % Records per buffer
gainAmp = 32*20;

NSD = false; % Noise Spectral Density
spectrumVolts = true; % Spectrum in volts
inputRange_volts = inputRangeIdToVolts(INPUT_RANGE_PM_1_V);

% Configure the board's sample rate, input, and trigger settings
if ~ATS9416ConfigureBoard(boardHandle,samplesPerSec)
  fprintf('Error: Board configuration failed\n');
  return
end

[result,bufferVolts] = ATS9416AcquireData_NPT(boardHandle, samplesPerSec, postTriggerSamples, average, buffersPerAcquisition, channelMask);

y = fftshift(fft(bufferVolts)); % Shift FFT around 0 Hz
L = length(bufferVolts); % Data length
y_fft = y(L/2+1:L); % Positive half of FFT
f = (1:(L/2)) * samplesPerSec/L; % FFT frequency

figure
if NSD == true
    P1 = zeros(1, length(f));
    for i = 1:length(f)
        P1(i) = abs(y_fft(i)) * 1/(sqrt(f(i))*L);
    end
    P1(1:end-1) = 2 * P1(1:end-1); % (end) corresponds to Nyquist frequencies
    loglog(f, P1/gainAmp)
    xlabel('Frequency (Hz)')
    ylabel('NSD (V/\surd{Hz})')

elseif spectrumVolts == true
    P1 = abs(y_fft) * 1/L;
    P1(1:end-1) = 2 * P1(1:end-1); % (end) corresponds to Nyquist frequencies
    loglog(f, P1/gainAmp)
    xlabel('Frequency (Hz)')
    ylabel('V')
    
else
    P1 = abs(y_fft) * 1/L;
    P1(1:end-1) = 2 * P1(1:end-1); % (end) corresponds to Nyquist frequencies
    plot(f, P1/gainAmp)
    xlabel('Frequency (Hz)')
    ylabel('V')
end

clear bufferVolts y yfft P1 P2