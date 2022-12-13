function [currentFolder] = getCurrentDataFolder(path,format)
    dateString = datestr(now(),format);
    currentFolder = catFileAndFolders(path,dateString);
    if ~exist(currentFolder,'dir')
        mkdir(path,dateString);
    end
end