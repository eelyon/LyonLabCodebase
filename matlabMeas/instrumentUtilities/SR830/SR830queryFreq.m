function [freq] = SR830queryFreq(Instrument)
    freq = query(Instrument, 'FREQ ?');
end

