function [] = set33220VoltageOffset(Instrument,voltageOffset)
    command = ['VOLTAGE:OFFS ', num2str(voltageOffset)];
    sendCommand(Instrument,command);
end

