function [xDat,yDat] = getXYData(figPath,varargin)
    defaultFieldNum = 1;
    defaultType = 'line';
    p = inputParser;
    addRequired(p,'figPath',@ischar);
    addParameter(p,'fieldNum',defaultFieldNum,@isnumeric);
    addParameter(p,'type',defaultType,@ischar);
    parse(p,figPath,varargin{:});
    
    fig = openfig(figPath,'invisible');
    h = findall(gcf,'Type',p.Results.type);
    xDat = h(p.Results.fieldNum).XData;
    yDat = h(p.Results.fieldNum).YData;
    closeFigure(fig);
end