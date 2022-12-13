function [] = sweepGate(Device,Port,startVoltage,stopVoltage,deltaVoltage,waitTime)
    
if startVoltage > stopVoltage
    deltaVoltage = -1*deltaVoltage;
end

    V = startVoltage:deltaVoltage:stopVoltage;
    for Vout = V
        setVal(Device,Port,Vout);
        pause(waitTime);
    end
end

