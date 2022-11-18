function [trigType] = query33220TriggerSourceType(Instrument)
    trigType = query(Instrument,'TRIG:SOUR?');
end

