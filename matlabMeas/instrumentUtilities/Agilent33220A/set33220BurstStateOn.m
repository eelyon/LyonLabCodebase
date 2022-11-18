function [] = set33220BurstStateOn(Instrument,onOrOff)
    if onOrOff
        command = 'BURS:STAT ON';
    else
        command = 'BURS:STAT OFF';
    end

    sendCommand(Instrument,command);
end

