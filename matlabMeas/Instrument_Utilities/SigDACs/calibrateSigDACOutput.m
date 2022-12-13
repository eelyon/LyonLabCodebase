function [linFit] = calibrateSigDACOutput(DAC,Therm,channel,startVoltage,stopVoltage,numVoltages)
    stepSize = (stopVoltage - startVoltage)/numVoltages;
    currentSetVoltage = zeros(1,numVoltages);
    measuredVoltage = zeros(1,numVoltages);
    for i = 1:numVoltages+1
        currentVoltage = startVoltage + (i-1)*stepSize;
        sigDACSetVoltage(DAC,channel,currentVoltage);
        currentSetVoltage(i) = currentVoltage;
        measuredVoltage(i) = str2double(queryHP34401A(Therm));
    end
    linFit = polyfit(currentSetVoltage,measuredVoltage,1);
end