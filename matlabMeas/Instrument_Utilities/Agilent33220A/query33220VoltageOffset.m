function [offset] = query33220VoltageOffset(Instrument)
    offset = query(Instrument,'VOLT:OFFS?');
end

