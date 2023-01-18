function [figPath] = getFigPath(currentDatePath,figName)
    figName = [figName '.fig'];
    figPath = fullfile(currentDatePath,figName);
end