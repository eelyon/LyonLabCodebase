%% Frequency of temperature querying in seconds.
timeBetweenPoints = 10;
%% Initialize Thermometer type (this is related to your thermometer you have)
thermometerType = '939801';
Thermometer;
Therm = initializeThermometry(thermometerType);
%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,temperature] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
thermPlot = plotData(time,temperature,'xLabel',"Time (minutes)",'yLabel',"Temperature (K)",'color',"rx");
setDataSources(thermPlot,'time','temperature');

temperatureVsTime('time','temperature',Thermometer,timeBetweenPoints,Therm);

