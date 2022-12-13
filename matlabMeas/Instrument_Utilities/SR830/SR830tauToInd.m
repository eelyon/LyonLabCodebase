function [tind] = SR830tauToInd(tau)
    tauInd =    [0,     1,     2,      3,      4,    5,    6,     7,     8,      9,      10, 11, 12, 13, 14];
    tauVals =   [10e-6, 30e-6, 100e-6, 300e-6, 1e-3, 3e-3, 10e-3, 30e-3, 100e-3, 300e-3, 1,  3,  10, 30, 100];

    tauMapping = containers.Map(tauVals, tauInd);

    tind = tauMapping(tau);

end