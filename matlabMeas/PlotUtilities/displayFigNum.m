function [figMetaData] = displayFigNum(figNum,varargin)
    % Function displays a figure using its figure number and returns any
    % associated metadata. Since we have 2 naming conventions for now, 
    % this code supports the old (Kyle's) naming convention as well. To 
    % look for a file with that naming convention, pass in 'isKyle',1 in 
    % leave as is. 

    defaultVisibility = 1;
    defaultIsKyleNaming  = 0;
    % Parse optional arguments
    p = inputParser;
    addRequired(p,'figNum',@isnumeric);
    addParameter(p,'visibility',defaultVisibility,@isnumeric);
    addParameter(p,'isKyle',defaultIsKyleNaming,@isnumeric);
    parse(p,figNum,varargin{:});
    
    if p.Results.visibility
        vis = 'visible';
    else
        vis = 'invisible';
    end

    if p.Results.isKyle
        fileStr = ['/*Scan' num2str(figNum) '*.fig'];
    else
        fileStr = ['/*_' num2str(figNum) '.fig'];
    end
    
    dataPath = getDataPath();
    dataFolders = getSubDataFolders(dataPath);
    for i = 1:length(dataFolders)
        datePath = catFileAndFolders(dataPath,dataFolders{i});
        directoryKeyVal = [datePath fileStr];%[datePath '/*_' num2str(figNum) '.fig'];
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