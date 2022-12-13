function [] = set33220TriggerSource(Instrument,sourceType)
    validSourceTypes = 'IMM,EXT,BUS';
    if ~contains(validSourceTypes,sourceType)
        fprintf([sourceType ' is not a valid trigger source type. Valid types are:\n'])
        fprintf([validSourceTypes, '\n']);
    else
        command = ['TRIG:SOUR ' sourceType];
        sendCommand(Instrument,command);
    end
end

