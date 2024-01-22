startVoltage = .5;
voltageSteps = -.025;
stopVoltage = -1.5;
numVoltages = abs((stopVoltage - startVoltage)/(abs(voltageSteps)));

for i = 1:numVoltages
    currentVoltage = startVoltage +(i)*voltageSteps;
    setVal(DAC,1,currentVoltage);
    sweep1DMeasSR830({'Pair'},0,-0.25,-0.025,.1,5,{SR830},DAC,{2,1},1);
    sweep1DMeasSR830({'ST'},1,.75,0.0025,0.3,9,{SR830},DAC,{16},1);
    sweep1DMeasSR830({'Pair'},0,-.25,-0.025,.1,5,{SR830},DAC,{2,1},1);
    sweep1DMeasSR830({'ST'},1,.75,0.0025,0.3,9,{SR830},DAC,{16},1);
    setVal(DAC,10,1.5);delay(5);setVal(DAC,7,-2);delay(5);setVal(DAC,10,0.5);setVal(DAC,7,1);
end

%sweepGatePairs(DAC,DAC,1,2,-3,-3,100,.01)