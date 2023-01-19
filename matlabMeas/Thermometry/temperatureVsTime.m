function [] = temperatureVsTime(xName,yName,Thermometer,timeBetweenPoints,therm)

i=1;
handle = gcf;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(handle));
while 1
    resistance = queryHP34401A(Thermometer);
    time(i) = (now()-startTime)*86400/60;
    assignin('base',xName,time);
    temperature(i) = therm.tempFromRes(resistance);
    assignin('base',yName,temperature);
    i = i+1;
    if ~mod(i,2)
        refreshdata;
        drawnow;
    end
    pause(timeBetweenPoints)
end
    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'tVsTime');
    end
end