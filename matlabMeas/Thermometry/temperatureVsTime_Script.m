

%% Frequency of temperature querying in seconds.
timeBetweenPoints = 60;
%% Initialize Thermometer type (this is related to your thermometer you have)
thermometerType = '939801';
Thermometer;
Therm = initializeThermometry(thermometerType);
%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,temperature] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
p = plotData(time,temperature,'xLabel',"Time (minutes)",'yLabel',"Temperature (K)",'color',"rx");
p.XDataSource = 'time';
p.YDataSource = 'temperature';

temperatureVsTime('time','temperature',Thermometer,timeBetweenPoints,therm);

