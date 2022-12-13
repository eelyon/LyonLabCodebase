function [voltage] = querySIM900Voltage(instrument,port)
    command = ['VOLT? ' num2str(port)];
    voltage = query(instrument,command);
end

