%% Function to bulk set voltages on the DAC

channels = [1, 2, 3, 4, 5, 6, 7, 8];
numSteps = 100;

voltsEmitt = [-0.0,...  %DAC 1
        -0.3,...   %DAC 2
        -1.5,...   %DAC 3
        -1.5,...   %DAC 4
        -0.0,...   %DAC 5
        -1.0,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

voltsEmittMeas = [-0.5,...  %DAC 1
        -0.4,...   %DAC 2
        -1.5,...   %DAC 3
        -1.5,...   %DAC 4
        0,...   %DAC 5
        -1,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

voltsEmittST = [-1,...  %DAC 1
        -0.0,...   %DAC 2
        -0.8,...   %DAC 3
        -0.3,...   %DAC 4
        0,...   %DAC 5
        -1,...   %DAC 6
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
        -4,...   %DAC 3
        -4,...   %DAC 4
        -4,...   %DAC 5
        -4,...   %DAC 6
        0,...   %DAC 7
        0];     %DAC 8

voltsSucc = [3,...  %DAC 1
        -6,...   %DAC 2
        -6,...   %DAC 3
        -6,...   %DAC 4
        -6,...   %DAC 5
        -6,...   %DAC 6
        -6,...   %DAC 7
        0];     %DAC 8

%sigDACRampVoltage(DAC,channels,voltsEmitt,numSteps);

%sigDACRampVoltage(DAC,channels,voltsEmittTest,numSteps);

%sigDACRampVoltage(DAC,channels,voltsGnd,numSteps);

%voltUse = voltsEmitt;
%voltUse = voltsEmittMeas;
%voltUse = voltsEmittTest;
%voltUse = voltsSucc;
voltUse = voltsGnd;
%voltUse = voltsEmittST;

%%{
for i = 1:length(voltUse)
    rampVal(DAC,i, sigDACQueryVoltage(DAC, i), voltUse(i), 0.1, 0.03);
end
%}