function [] = plotVoltVsTime(plotHandleCell,subPlotFigure,SR830,timeBetweenPoints)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(subPlotFigure));
[time,voltReal,voltImag] = deal([]);

while 1
    time(i) = (now()-startTime)*86400/60;
    voltReal(i) = SR830.SR830queryX();
    voltImag(i) = SR830.SR830queryY();

    setPlotXYData(plotHandleCell{1},time,voltReal);
    setPlotXYData(plotHandleCell{2},time,voltImag);

    i = i+1;
    pause(timeBetweenPoints)
end
    function cleanMeUp(subPlotFigure)
        disp('Operation Terminated, saving data');
        saveData(subPlotFigure,'voltVsTime');
    end
end