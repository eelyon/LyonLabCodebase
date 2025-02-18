% This script performs spectral analysis on data measured with the Alazar
stopFreq = 10e6; % FFT stop frequency
points = 10112; % 1000064; % Needs to be multiple of 128 and at least 256 points
average = 1; % Records per buffer
buffersPerAcquisition = 1; % Set number of buffers
channelMask = CHANNEL_A; % Set channel to be measured

gainCryo = 9; % Gain of cryogenic amplifier circuit
gainFEMTO = 100*32/10; % Gain of FEMTO voltage amplifier
temp = 295; % Temperature in Kelvin

NSD = true; % Noise Spectral Density (nV/sqrt(Hz)
PSD = false; % Power Spectral Density (nV^2/Hz)

% Configure the board's sample rate, input, and trigger settings
samplesPerSec = 2*stopFreq; % Sampling rate = 2x FFT freq.
if ~ATS9416ConfigureBoard(boardHandle,samplesPerSec)
  fprintf('Error: Board configuration failed\n');
  return
end

[result,bufferVolts] = ATS9416AcquireData_NPT(boardHandle,points,average,buffersPerAcquisition,channelMask);

y = fftshift(fft(bufferVolts)); % Shift FFT around 0 Hz
L = length(bufferVolts); % Data length
y_fft = y(L/2+1:L); % Positive half of FFT
freq = (1:(L/2)) * samplesPerSec/L; % FFT frequency

if NSD == true
    P1 = zeros(1, length(freq));
    for i = 1:length(freq)
        P1(i) = abs(y_fft(i)).^2 * 1/(samplesPerSec*L);
    end
    P1(1:end-1) = 2 * P1(1:end-1); % end corresponds to Nyquist frequencies
    yData = sqrt(P1)/(gainCryo*gainFEMTO)*1e9;
    [~,myFig] = plotData(freq,yData,'xLabel',"Frequency (Hz)",'yLabel',"nV/\surd{Hz}",'color',"r-",'type', "loglog");
    annotation('textbox',[0.2 0.5 0.3 0.3],'String',[num2str(temp),'K, x',num2str(gainCryo),' Amp Gain, x',num2str(gainFEMTO),' FEMTO gain'],'FitBoxToText','on');
    saveData(myFig,'NSD');

elseif PSD == true
    P1 = zeros(1, length(freq));
    for i = 1:length(freq)
        P1(i) = abs(y_fft(i)).^2 * 1/(samplesPerSec*L);
    end
    P1(1:end-1) = 2 * P1(1:end-1); % end corresponds to Nyquist frequencies
    yData = P1/(gainCryo*gainFEMTO)*1e9;
    [~,myFig] = plotData(freq,yData,'xLabel',"Frequency (Hz)",'yLabel',"nV^{2}/Hz",'color',"r-",'type', "loglog");
    annotation('textbox',[0.2 0.5 0.3 0.3],'String',[num2str(temp),'K, x',num2str(gainCryo),' Amp Gain, x',num2str(gainFEMTO),' FEMTO gain'],'FitBoxToText','on');
    saveData(myFig,'PSD');
    
else % Simple FFT
    P1 = zeros(1, length(freq));
    for i = 1:length(freq)
        P1(i) = abs(y_fft(i)) * 1/L;
    end
    P1(1:end-1) = 2 * P1(1:end-1); % end corresponds to Nyquist frequencies
    yData = sqrt(P1)/(gainCryo*gainFEMTO)*1e9;
    [~,myFig] = plotData(freq,yData,'xLabel',"Frequency (Hz)",'yLabel',"nV",'color',"r-",'type', "loglog");
    annotation('textbox',[0.2 0.5 0.3 0.3],'String',[num2str(temp),'K, x',num2str(gainCryo),' Amp Gain, x',num2str(gainFEMTO),' FEMTO gain'],'FitBoxToText','on');
    saveData(myFig,'FFT');
end

clear bufferVolts y y_fft P1 freq yData % Clear some of the variables