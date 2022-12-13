function [voltage] = sigDACQueryVoltage(instrument,port)
    fprintf(instrument,['CH ' num2str(port)]);
    voltage = str2double(query(instrument,'VOLT?'));
end

