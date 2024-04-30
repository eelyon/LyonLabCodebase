%% Initialize workspace arrays. Must be in workspace to update plots properly.
[voltage,current] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
transPlot = plotData(voltage,current,'xLabel',"Vcc (Volts)",'yLabel',"Ic (A)",'color',"r.",'type',"plot");
collectorCurrentVsVoltage(vSource,DMM2,2,transPlot,1.5,0,0.05,0.01);
transPlot = plotData(voltage,current,'xLabel',"Vcc (Volts)",'yLabel',"Ic (A)",'color',"r.",'type',"plot");
collectorCurrentVsVoltage(vSource,DMM2,2,transPlot,0,1.5,0.05,0.01);