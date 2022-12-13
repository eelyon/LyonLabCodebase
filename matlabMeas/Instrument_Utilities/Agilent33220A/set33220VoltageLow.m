function [] = set33220VoltageLow(Instrument, lowVoltage)
    command = ['VOLT:LOW ', num2str(lowVoltage)];
    sendCommand(Instrument,command);
end

