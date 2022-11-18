function [yVal] = SR830queryY(Instrument)
     yVal = query(Instrument, 'OUTP ? 2');
end

