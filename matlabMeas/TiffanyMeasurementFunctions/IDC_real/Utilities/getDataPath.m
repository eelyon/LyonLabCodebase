function [dataPath] = getDataPath()
    currentPath = pwd;
    while(~exist([currentPath '/Data'],'dir'))
        cd('..')
        currentPath = pwd;
    end
    dataPath = [currentPath '/Data'];
end