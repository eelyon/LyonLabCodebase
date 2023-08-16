function [T] = addFigID(figText)
    figXLim = xlim;
    figYLim = ylim;
    T = text(figXLim(2)/2,figYLim(2),figText,'HorizontalAlignment','right','VerticalAlignment','top');
end

