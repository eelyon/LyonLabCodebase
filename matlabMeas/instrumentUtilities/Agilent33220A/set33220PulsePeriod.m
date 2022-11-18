function [] = set33220PulsePeriod(Instrument,periodInSeconds)
    command = ['PULS:PER ' num2str(periodInSeconds)];
    sendCommand(Instrument,command);
end

