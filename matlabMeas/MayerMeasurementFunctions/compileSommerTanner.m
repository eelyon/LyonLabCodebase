figArr = 8301:2:8319;

numFigsPlotted = 0;

leg = [];
for i = figArr
    figPath = findFigNumPath(i);
    [xDat,yDat,xLab,yLab,titleName] = getXYDataSubPlots(figPath{1},'type','errorbar','fieldNum',1);
    currentBias = 0.4 - 0.05*numFigsPlotted;
    legStr = strcat(num2str(currentBias),"V Bias");
    if numFigsPlotted == 0
        plotData(xDat,yDat,'xLabel',xLab,'yLabel',yLab,'title',titleName,'holdOn',1,'legend',legStr,'color',"b.-");
        
    else
        plot(xDat,yDat,'.-','DisplayName',legStr);
    end
    
    numFigsPlotted = numFigsPlotted + 1;
end

xline(.9425);

figArr = 8321:2:8335;

numFigsPlotted = 0;

leg = [];
for i = figArr
    figPath = findFigNumPath(i);
    [xDat,yDat,xLab,yLab,titleName] = getXYDataSubPlots(figPath{1},'type','errorbar','fieldNum',1);
    currentBias = -.1 - 0.05*numFigsPlotted;
    legStr = strcat(num2str(currentBias),"V Bias");
    if numFigsPlotted == 0
        plotData(xDat,yDat,'xLabel',xLab,'yLabel',yLab,'title',titleName,'holdOn',1,'legend',legStr,'color',"b.-");
    else
        plot(xDat,yDat,'.-','DisplayName',legStr);
    end
    
    numFigsPlotted = numFigsPlotted + 1;
end
        xline(.9425);
        xline(.8860)