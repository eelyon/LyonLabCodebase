%% Frequency of voltage querying in seconds.
timeBetweenPoints = 3;

%% Initialize workspace arrays. Must be in workspace to update plots properly.
[time,voltageR, voltageI] = deal(inf);

%% Create plot for thermometry,IDCs,Emitter and set the data sources for the figure handle below.
subPlotFigure = figure(getNextMATLABFigNum());

voltRHandle = subplot(1,2,1);
voltRPlot   = plotData(time,voltageR,'xLabel',"Time (minutes)",'yLabel',"Volt Real (V)",'color',"kx",'subPlot',1);

voltIHandle = subplot(1,2,2);
voltIPlot   = plotData(time,voltageI,'xLabel',"Time (minutes)",'yLabel',"Volt Imag (V)",'color',"rx",'subPlot',1);

axesCell = {voltRHandle,voltIHandle};
PlotCell = {voltRPlot,voltIPlot};
SR830Cell = VmeasE;
plotVoltVsTime(PlotCell,subPlotFigure,SR830Cell,timeBetweenPoints);
