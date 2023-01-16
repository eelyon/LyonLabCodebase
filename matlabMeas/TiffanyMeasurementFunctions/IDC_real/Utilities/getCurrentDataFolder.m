function [currentFolder] = getCurrentDataFolder(path,format)
    dateString = datestr(now(),format);
    currentFolder = fullfile(path,dateString);
    if ~exist(currentFolder,'dir')
        mkdir(path,dateString);
    end
end