function [T] = addFigID(figObject,figText)
    figAxis = figObject.Children;
    try 
        figAxis(1).Axes 
    catch
        uistack(figAxis(1),'bottom'); % allows you to save plots with text in title (defaults to top of list of children)
        figAxis = figObject.Children;
    end
    figXLimRight = figAxis(1).XLim(2);
    figYLimTop = figAxis(1).YLim(2);
    T = text(figXLimRight/2,figYLimTop,figText,'HorizontalAlignment','right','VerticalAlignment','top','Parent',figAxis(1));
end
