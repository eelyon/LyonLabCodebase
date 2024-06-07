figArr = 12551:1:12561;
[500,400,350,300,250,200,150,100,90,80,70];
numFigsPlotted = 0;

leg = [];
for i = figArr
    figPath = findFigNumPath(i);
    [xDataCell,yDataCell,xLab,yLab,titleName] = pullSR830Data(i,'Imag vs Bias',0);
    xDat = xDataCell{1};
    yDat = yDataCell{1};
    %legStr = strcat(num2str(currentBias),"V Bias");
    if numFigsPlotted == 0
        plotData(xDat,yDat,'xLabel',xLab,'yLabel',yLab,'title',titleName,'holdOn',1,'color',"b.-",'saveMeta',0);
        
    else
        plot(xDat,yDat,'.-','DisplayName',legStr);
    end
    
    numFigsPlotted = numFigsPlotted + 1;
end

