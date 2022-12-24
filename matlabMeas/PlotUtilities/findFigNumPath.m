function figPaths = findFigNumPath(figNum)
    % Function returns a cell array of all the paths associated with a
    % figure number in the /Data folder.
    %
    % Inputs: 
    %        figNum - numeric tag that identifies the targeted figure.
    dataPath = getDataPath();
    dataFolders = getSubDataFolders(dataPath);
    figPaths = {};
    for i = 1:length(dataFolders)
        datePath = fullfile(dataPath,dataFolders{i});
        regex = ['*_' num2str(figNum) '.fig'];
        directoryKeyVal = fullfile(datePath,regex);
        figFiles = dir(directoryKeyVal);
        figNames = {figFiles.name};
        if ~isempty(figNames)
            for j = 1:length(figNames)
                currentFilePath = fullfile(datePath,figNames{j});
                figPaths{j} = currentFilePath;
            end
        end
    end
end

