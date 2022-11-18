function [] = set4WireRange(Instrument,Range)
    command = ['CONF:FRES ' num2str(Range)];
    sendCommand(Instrument, command);
end