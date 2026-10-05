%% Frequency of temperature querying in seconds.
timeBetweenPoints = 10;

%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,resistance] = deal(inf);
%% Create plot for thermometry and set the data sources for the figure handle below.
[resPlot,figHandle] = plotData(time,resistance,'xLabel',"Time (minutes)",'yLabel',"Resistance (Ohm)",'color',"rx");
flush(Multimeter);
resistanceVsTime(Multimeter,timeBetweenPoints,figHandle,resPlot);