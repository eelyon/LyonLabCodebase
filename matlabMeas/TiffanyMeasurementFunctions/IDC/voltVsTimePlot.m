%% Frequency of temperature querying in seconds.
timeBetweenPoints = 0.01;
%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,voltage] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
STEPlot   = plotData(time,voltage,'xLabel',"Time (minutes)",'yLabel',"Voltage (V)",'color',"kx");

plotVoltVsTime(VmeasE,timeBetweenPoints,STEPlot)

