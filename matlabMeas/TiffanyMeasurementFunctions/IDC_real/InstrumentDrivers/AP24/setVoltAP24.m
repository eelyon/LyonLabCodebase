function [errorflag] = setVoltAP24( AP24, Port, Volt )
    calibrate = 0;
    fprintf(AP24,['CH ' num2str(Port)]);
    errorflag = 0;

    if calibrate
        Folder = 'CalibrateDac\AP24\';
        load([Folder 'CH' num2str(Port) '.mat']);
        value = Volt;
        vRange = -9.8:0.49:9.8;
        new = interp1(vRange, vRange*m+b, value);
        newVolt = (value-new)+value;
        fprintf(AP24,['VOLT ' num2str(newVolt)])
    else
        fprintf(AP24,['VOLT ' num2str(Volt)])
    end    
end