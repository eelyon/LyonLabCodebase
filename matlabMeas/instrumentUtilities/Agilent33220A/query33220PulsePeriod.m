function [period] = query33220PulsePeriod(Instrument)
    period = query(Instrument,'PULS:PER?');
end

