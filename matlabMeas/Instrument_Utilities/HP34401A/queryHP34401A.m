function [output] = queryHP34401A(Instrument)
    output = str2double(query(Instrument,'READ?'));
end

