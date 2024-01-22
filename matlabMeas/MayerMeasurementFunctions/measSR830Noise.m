startFreq = 500;
stopFreq = 10000;
deltaFreq = 100;
input('Change SR830 displays to X and Y Noise');

numFreqs = (stopFreq - startFreq)/deltaFreq + 1;
xNoi = [];
yNoi = [];
freq = [];
for i = 1:numFreqs
    currentFreq = startFreq + deltaFreq*(i-1);
    freq(i) = currentFreq;
    SR830.SR830setFreq(currentFreq);
    delay(10);
    noiseStr = query(SR830.client,'SNAP? 10,11');
    noiseCell = split(noiseStr,',');
    xNoi(i) = str2num(noiseCell{1});
    yNoi(i) = str2num(noiseCell{2});
end

plotData(freq,xNoi,'xLabel',"Frequency (Hz)",'yLabel',"In Phase Noise (V/rt(Hz))");
plotData(freq,yNoi,'xLabel',"Frequency (Hz)",'yLabel',"Quadrature Noise (V/rt(Hz))");