% for some reason you need to run this code twice each time for it to work...

startNum = 7369;
stopNum = 7375;

numFigs = stopNum-startNum;
%fig = figure(801);
%delay(1);
oldNumShots = 1;

for i = 1:numFigs
    currentFigNum = startNum + (i-1);
    [currentFigMetaData,figHandle] = displayFigNum(currentFigNum,'visibility',0);
    closeFigure(figHandle);
    % delay(.25);

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



