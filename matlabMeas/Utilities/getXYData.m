function [xDat yDat] = getXYData(figPath,fieldNum)
    openfig(figPath,'invisible');
    h = findobj(gca,'Type','line');
    xDat = h(fieldNum).XData;
    yDat = h(fieldNum).YData;
end