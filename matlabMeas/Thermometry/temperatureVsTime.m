function [] = temperatureVsTime(Thermometer,timeBetweenPoints,therm,pHandle)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(pHandle));
time = [];
temperature = [];
while 1
    resistance = queryHP34401A(Thermometer);
    time(i) = (now()-startTime)*86400/60;
    temperature(i) = therm.tempFromRes(resistance);
    i = i+1;
    pHandle.YData = temperature;
    pHandle.XData = time;
    refreshdata;
    drawnow;
    pause(timeBetweenPoints)
end
    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'tVsTime');
    end
end