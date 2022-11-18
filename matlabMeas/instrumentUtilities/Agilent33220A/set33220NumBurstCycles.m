function [] = set33220NumBurstCycles(Instrument,numCycles)
    command = ['BURS:NCYC ' num2str(numCycles)];
    sendCommand(Instrument,command);
end

