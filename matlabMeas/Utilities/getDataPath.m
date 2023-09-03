function [dataPath] = getDataPath()
currentPath = pwd;
if ~contains(pwd,'matlabMeas')
    fprintf('ERROR! To run getDataPath() you must be in the matlabMeas folder!');
    dataPath = -1;
else
    while(~exist(fullfile(currentPath,'Data'),'dir'))
        cd('..')
        currentPath = pwd;
    end
    dataPath = fullfile(currentPath,'Data');
end

end