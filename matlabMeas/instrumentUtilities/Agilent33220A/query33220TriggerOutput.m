function [trigOutp] = query33220TriggerOutput(Instrument)
    trigOutp = query(Instrument,'OUTP:TRIG?');
end

