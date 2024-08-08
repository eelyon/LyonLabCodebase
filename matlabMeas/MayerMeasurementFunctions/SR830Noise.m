xNoi = [];
yNoi = [];
xNoise = [];
yNoise = [];

xErr = [];
yErr = [];
numPoints = 100;

amplitudes = 10000:10000:100000;
currentAmplitude = 1;
CIVector = tinv([0.025 0.975], numPoints-1); 
errorType = 'CI';
for amplitude = amplitudes
amplitude
SR830Twiddle.SR830setFreq(amplitude);
%SR830Twiddle.SR830setAmplitude(amplitude);
%set33622AAmplitude(Ag2Channel,amplitude,'VPP',1);
fprintf(SR830Twiddle.client,'AGAN')
delay(10);
for i = 1:numPoints
noiseStr = query(SR830Twiddle.client,'SNAP? 10,11');
noiseCell = split(noiseStr,',');
xNoi(i) = str2num(noiseCell{1});
yNoi(i) = str2num(noiseCell{2});

end

xNoise(currentAmplitude) = (sum(xNoi)/length(xNoi));
yNoise(currentAmplitude) = (sum(yNoi)/length(yNoi));
xErr(currentAmplitude) = calculateErrorBar(errorType,CIVector,xNoi,100);
yErr(currentAmplitude) = calculateErrorBar(errorType,CIVector,yNoi,100);
currentAmplitude = currentAmplitude+1;
%SR830Twiddle.SR830setSensitivity(26);
end

%amplitudes = amplitudes.*0.1;
xErr = xErr.*1e9;yErr = yErr.*1e9; xNoise= xNoise.*1e9;yNoise = yNoise.*1e9;
figure(806);
errorbar(amplitudes,yNoise,yErr);
hold on;
errorbar(amplitudes,xNoise,xErr);