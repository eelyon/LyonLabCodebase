function [voltage] = query33220VoltageHigh(Instrument)
    voltage = query(Instrument,'VOLT:HIGH?');
end

