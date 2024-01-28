startVoltage = .5;
voltageSteps = -.025;
stopVoltage = -1.5;
numVoltages = abs((stopVoltage - startVoltage)/(abs(voltageSteps)));
%v1 = -.1:-.05:-1.5;
%v2 = -1.5:-.01:-2.5;
%voltages = [v1 v2];
voltages = -1.05:-.025:-1.5;
for currentVoltage = voltages
    setVal(DAC,1,currentVoltage);
    sweep1DMeasSR830({'ST'},1,.8,0.0025,0.3,16,{SR830},DAC,{16},1);
    for i = 1:10
        sweep1DMeasSR830({'Pair'},0,-0.225,-0.025,.1,5,{SR830},DAC,{2,1},1);
        
    end
    closeAllFigures;
    sweep1DMeasSR830({'ST'},1,.8,0.0025,0.3,16,{SR830},DAC,{16},1);
    %sweep1DMeasSR830({'Pair'},0,-.25,-0.025,.1,5,{SR830},DAC,{2,1},1);
    %sweep1DMeasSR830({'ST'},1,.75,0.0025,0.3,9,{SR830},DAC,{16},1);
    setVal(DAC,10,3);delay(5);setVal(DAC,16,-1),delay(5);setVal(DAC,9,-2);setVal(DAC,7,-2);delay(5);setVal(DAC,10,0.5);setVal(DAC,7,1);delay(1);setVal(DAC,16,1);delay(1);setVal(DAC,9,1);

end

sweep1DMeasSR830({'Pair'},0,-1.5,-0.025,.1,5,{SR830},DAC,{2,1},1);
sweep1DMeasSR830({'ST'},1,.5,0.0025,0.3,16,{SR830},DAC,{16},1);
%sweepGatePairs(DAC,DAC,1,2,-3,-3,100,.01)