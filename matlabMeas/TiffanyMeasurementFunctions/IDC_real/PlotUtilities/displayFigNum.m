function [figMetaData] = displayFigNum(figNum)
    dataPath = getDataPath();
    dataFolders = getSubDataFolders(dataPath);
    for i = 1:length(dataFolders)
        datePath = fullfile(dataPath,dataFolders{i});
        directoryKeyVal = [datePath '/*_' num2str(figNum) '.fig'];
        figFiles = dir(directoryKeyVal);
        figNames = {figFiles.name};
        if(length(figNames) > 0)
            figMetaData = {};
            for j = 1:length(figNames)
                currentFilePath = fullfile(datePath,figNames{j});
                fig=openfig(currentFilePath);
                figMetaData{j} = fig.UserData;
            end
            return
        end
    end
    figMetaData = 0;
end