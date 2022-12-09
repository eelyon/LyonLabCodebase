function [bigGlassTemp] = bigGlassTemp(DMM, thermom)
    addpath(genpath(strcat(upDirMult(pwd, 2), '\instrumentUtilities')));
    R = queryHP34401A(DMM);
    bigGlassTemp = temp(thermom, R);
end