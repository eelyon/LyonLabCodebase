function [metaData] = getFigMetaData(figNum)
    % Function for extracting meta data from a matlab figure.
    % Returns error message if no meta data is found.
    % param figNum: number of figure from Data folder
    metaDataCell = displayFigNum(figNum,'visibility',0);
    metaData = metaDataCell{1};

    if isempty(metaData)
        fprintf('Error: No meta data found\n');
    end
end