function [] = testSiglentDoor(scope,masterTrigger,dev,startTime,stopTime,deltaTime)
times = startTime:deltaTime:stopTime;

for time = times
    disp(strcat("Current Time ", num2str(time)," second"));
    configSig5122TauBurst(dev,2,time);

    if ~strcmp(queryTDS2022TriggerState(scope),'READY')
        primeTDS2022ForAcquisition(scope);
    else
        disp('Oscilloscope is primed for acquisition');
    end
    pause(1);
    send33220Trigger(masterTrigger);
    %pause(1);
    figHandle = get2ChannelTDS2022Data(scope);
end

end

