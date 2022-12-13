function [pulseWidth] = query33220PulseWidth(Instrument)
    pulseWidth = query(Instrument,'FUNC:PULS:WIDT?');
end

