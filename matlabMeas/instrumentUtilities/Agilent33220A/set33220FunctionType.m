function [] = set33220FunctionType(Instrument,type)

    validTypes = 'SIN,SQU,RAMP,PULS,NOIS,DC,USER';
    if ~contains(validTypes,type)
        fprintf('Valid function types for the 33220 are:\n');
        fprintf([validTypes '\n'])
    else 
        command = ['FUNC ', type];
        sendCommand(Instrument,command);
    end

end

