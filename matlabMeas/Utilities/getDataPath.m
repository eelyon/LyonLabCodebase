function [dataPath] = getDataPath()
    currentPath = pwd;
    while(~exist(fullfile(currentPath,'Data'),'dir'))
        cd('..')
        currentPath = pwd;
    end
    dataPath = fullfile(currentPath,'Data');
end