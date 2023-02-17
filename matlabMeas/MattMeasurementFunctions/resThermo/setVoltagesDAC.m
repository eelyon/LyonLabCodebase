%% Function to bulk set voltages on the DAC

volts = [5,...  %DAC 1
        0,...   %DAC 2
        1,...   %DAC 3
        -0.5,...   %DAC 4
        0.5,...   %DAC 5
        0,...   %DAC 6
        0,...   %DAC 7
        -5];     %DAC 8

for i = 1:length(volts)
    setVal(DAC,i,volts(i));
end