function [] = displayFigure(date,figName)
    dataPath = getDataPath();
    figName = [figName '.fig'];
    dataPath = catFileAndFolders(dataPath,date);
    figPath = catFileAndFolders(dataPath,figName);
    if exist(figPath,"file")
        openfig(figPath);
    else
        msg = [figPath ' is not a valid path. Cannot open file.'];
        error(msg)
    end
end