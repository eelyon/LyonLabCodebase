%% Initialize workspace arrays. Must be in workspace to update plots properly.
[voltage,current] = deal(inf);

%% Create plot for thermometry and set the data sources for the figure handle below.
transPlot = plotData(voltage,current,'xLabel',"Vbb (Volts)",'yLabel',"Ib (A)",'color',"r.",'type',"plot");
divider = 1;
startVolt = 0*divider;
stopVolt = 0.6*divider;
resistor = 5e3;
baseCurrentVsVoltage(vSource,DMM1,1,transPlot,startVolt,stopVolt,0.05,resistor,divider,0.01);