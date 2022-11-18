function [] = set33220TriggerOutput(Instrument,onOrOff)
    if onOrOff
        command = 'OUTP:TRIG ON';
    else
        command = 'OUTP:TRIG OFF';
    end
    sendCommand(Instrument,command);
end

