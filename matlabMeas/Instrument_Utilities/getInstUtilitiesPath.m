function [utilitiesPath] = getInstUtilitiesPath()
    currentPath = pwd;
    while(~exist(fullfile(currentPath,"Instrument_Utilities"),'dir'))
        cd('..')
        currentPath = pwd;
    end
    utilitiesPath = fullfile(currentPath,"Instrument_Utilities");
end

