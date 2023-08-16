CPMGPath = findFigNumPath(1686);
[QxDat,QyDat] = getXYData(CPMGPath{1},'fieldNum',7);
[IxDat,IyDat] = getXYData(CPMGPath{1},'fieldNum',8);

startTimeInUs = QxDat(1)*1e6;
targetCenterInUs = 63;
targetCenterInSamples = (targetCenterInUs - startTimeInUs)/4e-3;
widthInUs = 6;
widthInSamples = 6/4e-3;
tauInUs = 30;
centerSpacingInUs = tauInUs*2;
centerSpacingInSamples = centerSpacingInUs/4e-3;
phaseArr = [];
piPulseNum = [];
totalPulseNum = 200;

for i = 1:totalPulseNum
    currentCenter = targetCenterInSamples + centerSpacingInSamples*(i-1);
    currentIEcho = IyDat(round(currentCenter - widthInSamples/2):round(currentCenter + widthInSamples/2));
    currentQEcho = QyDat(round(currentCenter - widthInSamples/2):round(currentCenter + widthInSamples/2));
    piPulseNum(i) = i;
    phaseArr(i) = calculateEchoPhase(currentIEcho,currentQEcho);
end

plotData(piPulseNum,phaseArr,'xlabel',"\pi pulse number",'ylabel',"Echo Phase (in degrees)",'color',"r.");