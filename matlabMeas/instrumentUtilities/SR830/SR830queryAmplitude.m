function [amp] = SR830queryAmplitude(Instrument)
    amp = query(Instrument,'SLVL ?');
end

