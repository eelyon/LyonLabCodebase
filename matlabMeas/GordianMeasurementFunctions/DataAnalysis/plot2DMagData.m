startNum = 10071;
stopNum = 10086;

numFigs = stopNum - startNum;
oldNumShots = 1;

for i = 0:numFigs
    currentFigNum = startNum + i;
    [currentFigMetaData,figHandle] = displayFigNum(currentFigNum,'visibility',0);
    closeFigure(figHandle);
    pause(0.02);  % need this pause for code to work the first time, waits for figures to close

    shotNumArr = split(currentFigMetaData{1}.numShots,' ');
    currentNumShots = str2num(shotNumArr{1});

    figPathCell = findFigNumPath(currentFigNum);
    figPath = figPathCell{1};
    [xDat,yDat] = getXYData(figPath,'Type','line','FieldNum',2);
    
    if i == 1
        plotData(xDat,yDat);
        hold on;
    else
        if oldNumShots ~= currentNumShots
        plot(xDat,yDat);
        oldNumShots = currentNumShots;
        % display(['Shot Number ' num2str(currentNumShots)]);
        end
    end
end



