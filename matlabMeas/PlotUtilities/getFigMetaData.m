function [metaData] = getFigMetaData(figNum)
    metaDataCell = displayFigNum(figNum,'visibility',0);
    metaData = metaDataCell{1};
end