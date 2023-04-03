function [calVolt, uncalVolt] = CheckCalibration(AP24, Rtemp, Port, Value)
    % call function with [x,y]=CheckCalibration(AP24, Rtemp, 23, 1)
    
    Folder = 'CalibrateDac\AP24\';
    load([Folder 'CH' num2str(Port) '.mat']);
    
    vRange = -9.8:0.49:9.8;
    new = interp1(vRange, vRange*m+b, Value);
    newVolt = (Value-new)+Value;
    
    setVoltAP24(AP24,Port,newVolt);
    calVolt = query(Rtemp,'READ?');
    
    setVoltAP24(AP24,Port, Value);
    uncalVolt = query(Rtemp,'READ?');
end
