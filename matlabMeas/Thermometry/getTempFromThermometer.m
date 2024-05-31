function [temperature] = getTempFromThermometer(Multimeter,Thermometer)
    resistance = queryHP34401A(Multimeter);
    temperature = Thermometer.tempFromRes(resistance);
end

