figNum = 1553;
CPMGPath = findFigNumPath(figNum);
% [QxDat,QyDat] = getXYData(CPMGPath{1},'fieldNum',7);
% [IxDat,IyDat] = getXYData(CPMGPath{1},'fieldNum',8);

startTimeInUs = QxDat(1)*1e6;
targetCenterInUs = 63;
targetCenterInSamples = (targetCenterInUs - startTimeInUs)/4e-3;
widthInUs = 12;
widthInSamples = widthInUs/4e-3;
tauInUs = 30.0;
centerSpacingInUs = tauInUs*2;
centerSpacingInSamples = centerSpacingInUs/4e-3;
IArr = [];
QArr = [];
MagArr = [];
piPulseNum = [];
totalTimeArr = [];
totalPulseNum = 2000;

for i = 1:totalPulseNum
    currentCenter = targetCenterInSamples + centerSpacingInSamples*(i-1);
    currentIEcho = IyDat(round(currentCenter - widthInSamples/2):round(currentCenter + widthInSamples/2));
    currentQEcho = QyDat(round(currentCenter - widthInSamples/2):round(currentCenter + widthInSamples/2));
    if i == 2000
        currentX = IxDat(round(currentCenter - widthInSamples/2):round(currentCenter + widthInSamples/2));
        plotData(currentX,currentIEcho)
    end
    IArr(i) = sum(sqrt(currentIEcho.^2));
    QArr(i) = sum(sqrt(currentQEcho.^2));
    MagArr(i) = sum(sqrt(currentIEcho.^2+currentQEcho.^2));
    piPulseNum(i) = i;
    totalTimeArr(i) = currentCenter*4e-9;
end

plotData(piPulseNum,IArr,'xlabel',"\pi pulse number",'ylabel',"Echo Phase (in degrees)",'color',"g.",'holdOn',1);
plotData(piPulseNum,QArr,'xlabel',"\pi pulse number",'ylabel',"Echo Phase (in degrees)",'color',"b.",'subPlot',1,'holdOn',1);
plotData(piPulseNum,MagArr,'xlabel',"\pi pulse number",'ylabel',"Echo Phase (in degrees)",'color',"r.",'subPlot',1,'holdOn',0,'legend',["I","Q","Mag"]);
addFigID(strcat("T2\_CPMG\_PiPulses\_",num2str(figNum)));

plotData(totalTimeArr,IArr,'color',"g.",'holdOn',1);
plotData(totalTimeArr,QArr,'color',"b.",'subPlot',1,'holdOn',1);
plotData(totalTimeArr,MagArr,'xlabel',"Time (s)",'ylabel',"Echo Phase (in degrees)",'color',"r.",'subPlot',1,'legend',["I","Q","Mag"]);
addFigID(strcat("T2\_CPMG\_",num2str(figNum)));