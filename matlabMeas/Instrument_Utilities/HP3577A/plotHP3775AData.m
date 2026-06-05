[datArr,freqArr] = pull3577AData(NetworkAnalyzer,1e3,5e6);
[hand,myFig] = plotData(freqArr,datArr,'xLabel',"Frequency (Hz)",'yLabel',"S_{21} (dB)",'color',"b-",'type',"semilogx");

% figure;
% legend('Measured S_{21}','Fit');
% xlabel('Frequency (Hz)');
% ylabel('Voltage Gain (arb. units)');