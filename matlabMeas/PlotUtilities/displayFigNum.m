function [figMetaData] = displayFigNum(figNum,varargin)
    defaultVisibility = 1;
    
    % Parse optional arguments
    p = inputParser;
    addRequired(p,'figNum',@isnumeric);
    addParameter(p,'visibility',defaultVisibility,@isnumeric);
    parse(p,figNum,varargin{:});
    
    if p.Results.visibility
        vis = 'visible';
    else
        vis = 'invisible';
    end
    
    dataPath = getDataPath();
    dataFolders = getSubDataFolders(dataPath);
    for i = 1:length(dataFolders)
        datePath = catFileAndFolders(dataPath,dataFolders{i});
        directoryKeyVal = [datePath '/*_' num2str(figNum) '.fig'];
        figFiles = dir(directoryKeyVal);
        figNames = {figFiles.name};
        if ~isempty(figNames)
            figMetaData = cell(1,length(figNames));
            for j = 1:length(figNames)
                currentFilePath = catFileAndFolders(datePath,figNames{j});
                fig=openfig(currentFilePath,'reuse',vis);
                figMetaData{j} = fig.UserData;
            end
            
            return
        end
    end
    figMetaData = 0;
end