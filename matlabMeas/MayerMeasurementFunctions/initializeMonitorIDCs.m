[time,current] = deal(inf);
IDCPlot = plotData(time,current,'xLabel',"Time (minutes)",'yLabel',"Imaginary Component (nA)",'color',"rx");
monitorIDCs(SR830,1,IDCPlot)

