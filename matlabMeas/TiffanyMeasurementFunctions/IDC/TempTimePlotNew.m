%% Frequency of temperature querying in seconds.
timeBetweenPoints = 5;

%% Initialize Thermometer type (this is related to your thermometer you have)
thermometerType = 'X189328';
Thermometer;
Therm = initializeThermometry(thermometerType);

%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,temperature, capacitance,current] = deal(inf);

%% Create plot for thermometry,IDCs,Emitter and set the data sources for the figure handle below.
subPlotFigure = figure(getNextMATLABFigNum());

subplot(2,2,1);
thermPlot = plotData(time,temperature,'xLabel',"Time (minutes)",'yLabel',"Temperature (K)",'color',"bx",'subPlot',1);

subplot(2,2,2);
IDCPlot   = plotData(time,capacitance,'xLabel',"Time (minutes)",'yLabel',"Capacitance (pF)",'color',"rx",'subPlot',1);

subplot(2,2,3:4);
STEPlot   = plotData(time,current,'xLabel',"Time (minutes)",'yLabel',"Current (nA)",'color',"kx",'subPlot',1);

tempPlotCell = {thermPlot,STEPlot,IDCPlot};
SR830Cell = {VmeasC,VmeasE};
currentTempVsTime(tempPlotCell,subPlotFigure,SR830Cell,timeBetweenPoints,Thermometer,Therm);
