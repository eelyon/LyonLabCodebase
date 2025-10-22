function [] = temperatureVsTime(Thermometer,timeBetweenPoints,therm,pHandle,figHandle)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(figHandle));
time = [];
temperature = [];

while 1
    resistance = queryHP34401A(Thermometer);

%     if resistance > 1e3
%         fprintf(Instrument, ['CONF:FRES ' num2str(1e6)]);
%     end

    time(i) = (now()-startTime)*86400/60;
    temperature(i) = therm.tempFromRes(resistance);
    figHandle.YData = temperature;
    figHandle.XData = time;
    title(['Temperature=' num2str(temperature(i)) 'K']);
    i = i+1;
    refreshdata;
    drawnow;
    delay(timeBetweenPoints);
end

function cleanMeUp(handle)
    disp('Operation Terminated, saving data');
    saveData(handle,'tVsTime');
end
end