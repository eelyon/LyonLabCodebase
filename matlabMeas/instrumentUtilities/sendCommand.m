function [] = sendCommand(Instrument,command)
    fwrite(Instrument,command);
end

