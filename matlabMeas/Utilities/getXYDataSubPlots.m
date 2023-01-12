function [xDat,yDat,xLab,yLab,titleName] = getXYDataSubPlots(figPath,varargin)
    % Subplot axes are actually in reverse order from what you expect (top
    % left is last element, bottom right is first element). You must
    % disclose the type of plot you're pulling data from, e.g. ErrorBar or
    % line. Default is line. FieldNum discloses which field to look at. In
    % our case of back and forth sweeps, there are two field nums (2 is
    % forward, 1 is backward). Default is 1.

    defaultPlotNum = 1;
    defaultFieldNum = 1;
    defaultType = 'line';
    p = inputParser;
    addRequired(p,'figPath',@ischar);
    addParameter(p,'plotNum',defaultPlotNum,@isnumeric);
    addParameter(p,'fieldNum',defaultFieldNum,@isnumeric);
    addParameter(p,'type',defaultType,@ischar);
    parse(p,figPath,varargin{:});
    
    fig = openfig(figPath,'invisible');
    ax = get(fig,'Children');
    targetAxis = findobj(ax(p.Results.plotNum),'Type',p.Results.type);
    xDat = targetAxis(p.Results.fieldNum).XData;
    yDat = targetAxis(p.Results.fieldNum).YData;
    xLab = ax(p.Results.plotNum).XLabel.String;
    yLab = ax(p.Results.plotNum).YLabel.String;
    titleName = ax(p.Results.plotNum).Title.String;
    closeFigure(fig);
end
