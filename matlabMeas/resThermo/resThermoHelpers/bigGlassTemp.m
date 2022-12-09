function [bigGlassTemp] = bigGlassTemp(DMM, thermom)
    addpath(genpath(strcat(upDir(pwd), '\instrumentUtilities')));
    R = queryHP34401A(DMM);
    bigGlassTemp = temp(thermom, R);
end