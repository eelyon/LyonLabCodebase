%% Initialize workspace arrays. Must be in workspace to update plots properly.
xDat = [0];
yDat = [0];

%% Create plot for thermometry and set the data sources for the figure handle below.
[p,handle] = plotData(xDat,yDat,'xLabel',"V_Top (V) (\Del V = 1V)",'yLabel',"ST Response (nA)",'color',"rx");
p.XDataSource = 'xDat';
p.YDataSource = 'yDat';

Dev1 = sigDAC;
Dev2 = sigDAC;
Port1 = 4;
Port2 = 2;
finalVoltage1 = -2;
finalVoltage2 = -1;
numSteps = 100;
waitTime = .03;

sweepGatePairs('xDat','yDat',Dev1,Dev2,Port1,Port2,finalVoltage1,finalVoltage2,numSteps,waitTime);