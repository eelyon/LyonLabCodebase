function [utilitiesPath] = getInstUtilitiesPath()
    currentPath = pwd;
    while(~exist([currentPath '\Instrument_Utilities'],'dir'))
        cd('..')
        currentPath = pwd;
    end
    utilitiesPath = [currentPath '\Instrument_Utilities'];
end

