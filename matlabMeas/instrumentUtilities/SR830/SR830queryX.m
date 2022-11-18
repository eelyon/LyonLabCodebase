function [xVal] = SR830queryX(Instrument)
    xVal = query(Instrument, 'OUTP ? 1');
end

