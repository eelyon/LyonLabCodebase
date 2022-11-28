function [tau] = SR830queryTau(Instrument)
    tauInd = query(Instrument, 'OFLT ?');

    tau = SR830indToTau(str2num(tauInd));
end

