function [currentFolder] = getCurrentDataFolder()
    dataPath = getDataPath();
    format = "mm_dd_yy";
    dateString = datestr(now(),format);
    currentFolder = fullfile(dataPath,dateString);
    if ~exist(currentFolder,'dir')
        mkdir(dataPath,dateString);
    end
end