function [] = setSIM900Voltage(instrument,port,voltage)
    voltageResolution = .001;
    currentVoltage = querySIM900Voltage(instrument,port);
    if abs(voltage - currentVoltage) > voltageResolution
        fprintf('Voltage step is too small for SIM900');
    else
        command = ['VOLT ' num2str(voltage)];
        fprintf(instrument,command);
    end
end

