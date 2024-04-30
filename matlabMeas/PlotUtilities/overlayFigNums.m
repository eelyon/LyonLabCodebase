function [] = overlayFigNums(figNumArray)
    % Overlays .fig file data onto a single figure. Currently does it onto
    % figure 800. 
    %
    % Input:  
    %         figNumArray - numeric array containing all .fig numbers that
    %         are to be overlayed.
    legCell = {};
    figNum = 1;
    xDats = {};
    yDats = {};
    
    for figureNumber = figNumArray
         legCell{figNum} = num2str(figureNumber);
         figPathCell = findFigNumPath(figureNumber);
         figPath = figPathCell{1};
         [xDat,yDat] = getXYData(figPath);
         xDats{figNum} = xDat.*1e9;
         yDats{figNum} = yDat./xDat;
         figNum = figNum + 1;
    end

    [xLabel,yLabel] = getXYLabel(figPathCell{1});
    for i = 1:length(xDats)
        if i == 1
            figure(getNextMATLABFigNum());
            plot(xDats{i},yDats{i});
            xlabel(xLabel);
            ylabel(yLabel);
            hold on
        else
            plot(xDats{i},yDats{i});
        end
    end
    legend(legCell)
end

