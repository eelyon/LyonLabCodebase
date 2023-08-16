function [calVolt, uncalVolt] = CheckCalibration(AP24, Rtemp, Port, Value)
    %% call function with [x,y]=CheckCalibration(AP24, Rtemp, 23, 1)
    %% x = new calibrated outcome, y = old uncalibrated voltage
    
    Folder = 'CalibrateDac\AP24\';
    load([Folder 'CH' num2str(Port) '.mat']);  % outputs m,b
    
    vRange = -9.8:0.49:9.8;
    new = interp1(vRange, vRange*m+b, Value);
    newVolt = (Value-new)+Value;
    
    sigDACSetVoltage(AP24,Port,newVolt); % see new calibrated voltage outputted
    calVolt = query(Rtemp,'READ?');
    
    sigDACSetVoltage(AP24,Port, Value); % compare with old uncalibrated voltage
    uncalVolt = query(Rtemp,'READ?');
end
