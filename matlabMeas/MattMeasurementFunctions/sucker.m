voltsGnd = [0,...  %DAC 1
        0,...   %DAC 2
        0,...   %DAC 3
        0,...   %DAC 4
        0,...   %DAC 5
        0,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

succer = -5;
voltsSucc = [8,...  %DAC 1
        succer,...   %DAC 2
        succer,...   %DAC 3
        succer,...   %DAC 4
        succer,...   %DAC 5
        succer,...   %DAC 6
        succer,...   %DAC 7
        succer];     %DAC 8

for j = 1:10
    for i = 1:3
        setVal(DAC,i,voltsSucc(i));
    end
    for i = 1:3
        setVal(DAC,i,voltsGnd(i));
    end
end