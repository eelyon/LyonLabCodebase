function [] = resistanceVsTime(device,timeBetweenPoints,pHandle,figHandle)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(figHandle));
time = [];
resistance = [];

while 1
    time(i) = (now()-startTime)*86400/60;
    resistance(i) = queryHP34401A(device);

%     if resistance > 1e3
%         fprintf(Instrument, ['CONF:FRES ' num2str(1e6)]);
%     end

    figHandle.YData = resistance;
    figHandle.XData = time;
    title(['Resistance=' num2str(resistance(i)*1e-3) 'kOhm']);
    i = i+1;
    refreshdata;
    drawnow;
    delay(timeBetweenPoints);
end

function cleanMeUp(handle)
    disp('Operation Terminated, saving data');
    saveData(handle,'rVsTime');
end
end