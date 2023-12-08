function [] = plotResVsTime(plotHandleCell,subPlotFigure,ENA,timeBetweenPoints,Thermometer,therm,axesCell,ENACell)
% plotHandleCell - cell containing all plot handles to update. Format:
% Temperature, current, capacitance
% device - contains ENA

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(subPlotFigure));
[time,frequency,temperature] = deal([]);

while 1
    time(i) = (now()-startTime)*86400/60;
    resistance = queryHP34401A(Thermometer);
    temperature(i) = therm.tempFromRes(resistance);
    fres = E5071FreqSweep(ENA,ENACell{1},ENACell{2},ENACell{3},ENACell{4},1);
    frequency(i) = fres;

    setPlotXYData(plotHandleCell{1},time,frequency);
    setPlotXYData(plotHandleCell{2},time,temperature);
    setPlotTitle(axesCell{1},'F',frequency(i));
    setPlotTitle(axesCell{2},'T',temperature(i));

    i = i+1;
    pause(timeBetweenPoints)
end
    function cleanMeUp(subPlotFigure)
        disp('Operation Terminated, saving data');
        saveData(subPlotFigure,'ResVsTemp');
    end
end