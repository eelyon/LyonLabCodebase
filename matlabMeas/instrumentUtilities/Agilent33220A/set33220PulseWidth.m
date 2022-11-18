function [] = set33220PulseWidth(Instrument, widthInSeconds)
    command = ['FUNC:PULS:WIDT ', num2str(widthInSeconds)];
    sendCommand(Instrument,command);
end

