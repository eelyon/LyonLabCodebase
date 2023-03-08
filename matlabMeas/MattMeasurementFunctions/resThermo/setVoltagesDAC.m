%% Function to bulk set voltages on the DAC

voltsEmitt = [-8,...  %DAC 1
        3,...   %DAC 2
        2,...   %DAC 3
        2,...   %DAC 4
        2,...   %DAC 5
        0,...   %DAC 6
        1,...   %DAC 7
        0];     %DAC 8

voltsKeep = [0,...  %DAC 1
        3,...   %DAC 2
        0,...   %DAC 3
        0,...   %DAC 4
        0,...   %DAC 5
        0,...   %DAC 6
        -1,...   %DAC 7
        0];     %DAC 8

voltsGnd = [0,...  %DAC 1
        0,...   %DAC 2
        0,...   %DAC 3
        0,...   %DAC 4
        0,...   %DAC 5
        0,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

voltUse = voltsKeep;

for i = 1:length(voltUse)
    setVal(DAC,i,voltUse(i));
end