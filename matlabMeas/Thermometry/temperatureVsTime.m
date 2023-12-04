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
    pHandle.YData = temperature;
    pHandle.XData = time;
    title(['Temperature=' num2str(temperature(i)) 'K']);
    i = i+1;
    refreshdata;
    drawnow;
    pause(timeBetweenPoints);
end

    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'tVsTime');
    end
end