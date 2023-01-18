function [] = displayFig(date,figName)
    dataPath = getDataPath();
    figName = [figName '.fig'];
    dataPath = fullfile(dataPath,date);
    figPath = fullfile(dataPath,figName);
    if exist(figPath,"file")
        openfig(figPath);
    else
        msg = [figPath ' is not a valid path. Cannot open file.'];
        error(msg)
    end
end