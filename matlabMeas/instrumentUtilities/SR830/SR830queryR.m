function [rVal] = SR830queryR(Instrument)
    rVal = query(Instrument, 'OUTP ? 3');
end

