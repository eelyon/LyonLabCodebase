toAnalyzePath = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_06_24\Test_Amp_Network_Analyzer.fig';
baselinePath = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_06_24\Baseline_Network_Analyzer.fig';

[xDatToAnalyze,yDatToAnalyze] = getXYData(toAnalyzePath);
[xDatBase, yDatBase] = getXYData(baselinePath);

netGain = yDatToAnalyze-yDatBase;

plotData(xDatToAnalyze,netGain,'xLabel',"Frequency (Hz)", 'yLabel',"Gain (dB)",'color',"r-");