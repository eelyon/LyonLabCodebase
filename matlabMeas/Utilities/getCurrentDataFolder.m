function [currentFolder] = getCurrentDataFolder()
    path = getDataPath();
    format = "mm_dd_yy";
    dateString = datestr(now(),format);
    currentFolder = fullfile(path,dateString);
    if ~exist(currentFolder,'dir')
        mkdir(path,dateString);
    end
end