function [xLabel,yLabel] = getXYLabel(figPath)
    openfig(figPath,'invisible');
    ax = gca;
    xLabel = ax.XLabel.String;
    yLabel = ax.YLabel.String;
end

