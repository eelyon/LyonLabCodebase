function [output] = queryHP34401A(Instrument)
    output = query(Instrument,'READ?');
end

