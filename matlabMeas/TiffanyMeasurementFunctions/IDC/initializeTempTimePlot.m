function [plotHandles,subPlotFigure] = initializeTempTimePlot()

[time,Imag] = deal(inf);

timeLabel = "Time [s]";

subPlotFigure = figure(getNextMATLABFigNum());
subplot(2,2,1);  % Emitter Current
realVsTime = plotData(time,Imag,'xLabel',timeLabel,'yLabel',"Emitter Current [nA]",'title',"Current vs Time",'subPlot',1);

subplot(2,2,2)  % IDC capacitance
imagVsTime = plotData(time,Imag,'xLabel',timeLabel,'yLabel',"IDC Capacitance [pF]",'title',"Capacitance vs Time",'subPlot',1);

subplot(2,2,3:4)  % Temperature
magVsTime = plotData(time,Imag,'xLabel',timeLabel,'yLabel',"Temperature [K]",'title',"Temperature vs Time",'subPlot',1);


plotHandles = {realVsTime,imagVsTime,magVsTime};
%tileFigures(subPlotFigure,1,1,2,[],[0,0,0.5,1]);

end

