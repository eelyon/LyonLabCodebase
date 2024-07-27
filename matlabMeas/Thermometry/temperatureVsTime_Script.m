%% Frequency of temperature querying in seconds.
timeBetweenPoints = 1;
%% Initialize Thermometer type (this is related to your thermometer you have)

<<<<<<< HEAD
thermometerType = 'X117656'; %Big Glass Dewar
%thermometerType = 'X189328'; %Small Glass Dewar
%thermometerType = 'X189327'; %CIA Stick
=======
%thermometerType = 'X117656'; %Big Glass Dewar
%thermometerType = 'X189328'; %Small Glass Dewar
thermometerType = 'X189327'; %CIA Stick
>>>>>>> 81d8bdd9ccb0d31e28767dccf235e6e0ffe38c09

Thermometer;
Therm = initializeThermometry(thermometerType);
%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,temperature] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
[thermPlot,figHandle] = plotData(time,temperature,'xLabel',"Time (minutes)",'yLabel',"Temperature (K)",'color',"rx");
flush(Thermometer);
temperatureVsTime(Thermometer,timeBetweenPoints,Therm,figHandle,thermPlot);

 