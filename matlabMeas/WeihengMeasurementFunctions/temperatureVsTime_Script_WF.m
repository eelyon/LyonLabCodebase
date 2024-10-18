%% Frequency of temperature querying in seconds.
timeBetweenPoints = 5;

%% Initialize Thermometer type (this is related to your thermometer you have)
thermometerType = 'X189327';
% Thermometer;
Therm = initializeThermometry(thermometerType);

port = 1234; % for the big glass dewar??
%% Thermometer
DMM_Address = '172.29.117.107';
Thermometer = TCPIP_Connect(DMM_Address,port);

%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,temperature] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
thermPlot = plotData(time,temperature,'xLabel',"Time (minutes)",'yLabel',"Temperature (K)",'color',"rx");

temperatureVsTime(Thermometer,timeBetweenPoints,Therm,thermPlot);
fclose(Thermometer);