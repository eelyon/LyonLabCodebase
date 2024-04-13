function [] = collectorCurrentVsVoltage(vSource,DMM,chan,pHandle,startVoltage,stopVoltage,deltaVoltage,waitTime)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(pHandle));
voltage_Vbb = [];
current_Ib = [];

deltaVoltage = checkDeltaSign(startVoltage,stopVoltage,deltaVoltage);
voltArr = startVoltage:deltaVoltage:stopVoltage;
currentVal = 1;
for i=voltArr   
    setVolt(vSource,chan,i);
    delay(waitTime);
    voltage_Vbb(currentVal) = queryVolt(vSource,chan);
    delay(waitTime);
    current_Ib(currentVal) = queryHP34401A(DMM);

    pHandle.YData = current_Ib;
    pHandle.XData = voltage_Vbb;
    currentVal = currentVal+1;
    refreshdata;
    drawnow;
end

    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'currentVsVolt');
    end
end