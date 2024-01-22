function [] = sweepGatePairs(Dev1,Dev2,Port1,Port2,finalVoltage1,finalVoltage2,numSteps,waitTime)

currentDev1Voltage = getVal(Dev1,Port1);
currentDev2Voltage = getVal(Dev2,Port2);


dev1Steps = (finalVoltage1 - currentDev1Voltage)/numSteps;
dev2Steps = (finalVoltage2 - currentDev2Voltage)/numSteps;

for i = 1:numSteps
    d1Voltage = currentDev1Voltage + dev1Steps*i;
    d2Voltage = currentDev2Voltage + dev2Steps*i;

    setVal(Dev1,Port1,d1Voltage);
    setVal(Dev2,Port2,d2Voltage);
   
    delay(waitTime);
end

end