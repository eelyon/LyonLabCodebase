function [] = checkDAC(DAC,numChans)
    for i = 1:numChans
        voltage = 0.2;
        setVal(DAC,i,voltage);
    end
end

