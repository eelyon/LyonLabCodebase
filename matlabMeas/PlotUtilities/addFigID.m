function [T] = addFigID(figObject,figText)
    figAxis = get(figObject,'CurrentAxes');
    figXLimRight = figAxis(1).XLim(2);
    figYLimTop = figAxis(1).YLim(2);
    T = text(figXLimRight/2,figYLimTop,figText,'HorizontalAlignment','right','VerticalAlignment','top','Parent',figAxis(1));
end
