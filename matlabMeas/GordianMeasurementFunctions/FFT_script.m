% Script for getting the FFT from noise data
figNum = 6140;

metaData = getFigMetaData(figNum); disp(metaData);
Ts = str2num(metaData.sTime)/str2num(metaData.numPoints); % Time increment per point
fs = 1/Ts; % Sampling rate

figPathCell = findFigNumPath(figNum);
figPath = figPathCell{1};
[xDat,yDat] = getXYData(figPath,'Type','line','FieldNum',1);

y = fft(yDat-median(yDat)); % Subtract median to remove noise floor
f = (0:length(y)-1)*fs/length(y); % FFT frequency
n = length(yDat); % Number of points
fshift = (-n/2:n/2-1)*(fs/n); % FFT frequency centered around 0 Hz
yshift = fftshift(y); % FFT data centered around 0 Hz

half = length(fshift)/2; % Index of half the array

figure
plot(fshift(half+1:end),abs(yshift(half+1:end)).^2/n);
xlabel('Frequency (Hz)')
ylabel ('Power (arb.)')