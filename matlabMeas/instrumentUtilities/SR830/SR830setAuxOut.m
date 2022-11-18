function [] = SR830setAuxOut(Instrument,auxOut,voltage)
    if auxOut > 4 || auxOut < 1
        fprintf('auxOut must be between 1-4');
    else
        command = ['AUXV ' num2str(auxOut) ', ' num2str(voltage)];
        fprintf(Instrument,command);
    end
end

