function [] = set33220VoltageHigh(Instrument,highVoltage)
    command = ['VOLT:HIGH ', num2str(highVoltage)];
    sendCommand(Instrument,command);
end

