function [] = checkDAC(DAC,numChans)
    for i = 1:numChans
        voltage = 0;
        setVal(DAC,i,voltage);
        % setVal(DAC,i,voltage+(i-1)*0.1);
    end
end

