%% Function to bulk set voltages on the DAC

channels = [1, 2, 3, 4, 5, 6, 7, 8];
numSteps = 100;

voltsEmittMeas = [-0.4,...  %DAC 1
        -0.20,...   %DAC 2
        -0.20,...   %DAC 3
        -0.0,...   %DAC 4
        -0.0,...   %DAC 5
        -0.0,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

voltsGnd = [0,...  %DAC 1
        0,...   %DAC 2
        0,...   %DAC 3
        0,...   %DAC 4
        0,...   %DAC 5
        0,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

voltsEmittTest = [0,...  %DAC 1
        -4,...   %DAC 2
        -0,...   %DAC 3
        -4,...   %DAC 4
        -0,...   %DAC 5
        -0,...   %DAC 6
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

voltUse = voltsEmittMeas;
%voltUse = voltsEmittTest;
%voltUse = voltsSucc;
%voltUse = voltsGnd;

%%{
for i = 1:length(voltUse)
    rampVal(DAC,i, sigDACQueryVoltage(DAC, i), voltUse(i), 0.05, 0.03);
    %setVal(DAC,i,voltUse(i));
    %pause(0.3);
end
%}