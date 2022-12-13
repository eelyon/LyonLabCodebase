function [] = sigDACSetVoltage(instrument,port,voltage)
    fprintf(instrument,['CH ' num2str(port)]);
    fprintf(instrument,['VOLT ' num2str(voltage)]);
end

