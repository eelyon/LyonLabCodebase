%% Frequency of temperature querying in seconds.
timeBetweenPoints = 3;

%% Initialize Thermometer type (this is related to your thermometer you have)

<<<<<<< Updated upstream
%thermometerType = 'X117656'; %Big Glass Dewar
thermometerType = 'X189328'; %Small Glass Dewar
=======
thermometerType = 'X117656'; %Big Glass Dewar
%thermometerType = 'X189328'; %Small Glass Dewar
>>>>>>> Stashed changes
%thermometerType = 'X204446'; %Dunking Thermometer
%thermometerType = 'X189327'; %CIA Stick

Thermometer;
Therm = initializeThermometry(thermometerType);
%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,temperature] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
[thermPlot,figHandle] = plotData(time,temperature,'xLabel',"Time (minutes)",'yLabel',"Temperature (K)",'color',"rx");
flush(Thermometer);
temperatureVsTime(Thermometer,timeBetweenPoints,Therm,figHandle,thermPlot);