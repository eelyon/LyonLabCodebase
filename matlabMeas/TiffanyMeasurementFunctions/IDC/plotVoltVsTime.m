function [] = plotVoltVsTime(SR830,timeBetweenPoints,pHandle)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(pHandle));
time = [];
voltage = [];
while 1
    time(i) = (now()-startTime)*86400/60;
    voltage(i) = -SR830.SR830queryX();    
    pHandle.YData = voltage;
    pHandle.XData = time;
    i = i+1;
    refreshdata;
    drawnow;
    pause(timeBetweenPoints)
end
    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'voltVsTime');
    end
end