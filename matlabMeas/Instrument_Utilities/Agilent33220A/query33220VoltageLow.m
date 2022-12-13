function [voltLow] = query33220VoltageLow(Instrument)
    voltLow = query(Instrument,'VOLT:LOW?');
end

