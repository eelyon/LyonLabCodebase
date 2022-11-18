function [auxVoltage] = SR830queryAuxOut(Instrument,auxOut)
    command = ['AUXV ? ' num2str(auxOut)];
    auxVoltage = query(Instrument,command);
end

