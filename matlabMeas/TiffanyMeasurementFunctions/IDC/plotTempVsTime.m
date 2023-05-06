function [] = plotTempVsTime(plotHandleCell,subPlotFigure,SR830,timeBetweenPoints,Thermometer,therm,axesCell)
% plotHandleCell - cell containing all plot handles to update. Format:
% Temperature, current, capacitance
% SR830 - cell containing SR830 objects to measure.

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(subPlotFigure));
[time,current,temperature,capacitance] = deal([]);
numSR830s = length(SR830);
frequency = SR830{numSR830s}.SR830queryFreq();
amplitude = SR830{numSR830s}.SR830queryAmplitude();
while 1
    time(i) = (now()-startTime)*86400/60;
    for SR830obj = 1:numSR830s
        if SR830obj == 1
            current(i) = -SR830{SR830obj}.SR830queryY();
        else
            capacitance(i) = -SR830{SR830obj}.SR830queryY()/(2*pi*frequency*amplitude);
        end
    end
    resistance = -queryHP34401A(Thermometer);
    temperature(i) = therm.tempFromRes(resistance);

    setPlotXYData(plotHandleCell{1},time,temperature);
    setPlotXYData(plotHandleCell{2},time,current);
    setPlotXYData(plotHandleCell{3},time,capacitance);
    setPlotTitle(axesCell{1},'T',temperature(i));
    setPlotTitle(axesCell{3},'C',capacitance(i));
    
    i = i+1;
    pause(timeBetweenPoints)
end
    function cleanMeUp(subPlotFigure)
        disp('Operation Terminated, saving data');
        saveData(subPlotFigure,'tempVsTime');
    end
end