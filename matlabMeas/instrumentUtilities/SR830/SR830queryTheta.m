function [thetaVal] = SR830queryTheta(Instrument)
    thetaVal = query(Instrument, 'OUTP ? 4');
end

