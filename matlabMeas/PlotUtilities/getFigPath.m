function [figPath] = getFigPath(currentDatePath,figName)
    figName = [figName '.fig'];
    figPath = catFileAndFolders(currentDatePath,figName);
end