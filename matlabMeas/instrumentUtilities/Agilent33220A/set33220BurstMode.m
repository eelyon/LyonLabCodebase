function [] = set33220BurstMode(Instrument,burstType)
    validTypes = 'TRIG,GAT';
    if ~contains(validTypes,burstType)
        fprintf('Invalid burst type, valid types are:\n');
        fprintf(validTypes);
    else
        command = ['BURS:MODE ' burstType];
        sendCommand(Instrument,command);
    end
end

