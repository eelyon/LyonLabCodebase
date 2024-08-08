AmpPath = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_15_24\PSD_12971.fig';
BackgroundPath = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_06_24\Just_Femto_PSD.fig';

[AmpX,AmpY] = getXYData(AmpPath);
[BackX,BackY] = getXYData(BackgroundPath);

NormAmpY = AmpY;

AmpGainInVoltage = 33;
FemtoGainInVoltage = 10;

netVoltageGain = AmpGainInVoltage*FemtoGainInVoltage;

NormAmpY = NormAmpY./netVoltageGain;
PSDInNV = NormAmpY;

plotData(AmpX,PSDInNV,'xLabel',"Frequeny (Hz)",'yLabel',"Power Spectral Density ($\frac{nV}{\sqrt{Hz}}$)",'color',"r-",'type', "loglog");
delay(1);
currAxes = gca();
currAxes.YLabel.Interpreter = 'latex';
