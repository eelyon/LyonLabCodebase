function [xLabel,yLabel] = getXYLabel(figPath)
    fig = openfig(figPath,'invisible');
    ax = gca;
    xLabel = ax.XLabel.String;
    yLabel = ax.YLabel.String;
    closeFigure(fig);
end

