function [voltageRatio] = convertdBmToVoltage(yIndBm)
voltageRatio = [];

for i = 1:length(yIndBm)
    voltageRatio(i) = 10^(yIndBm(i)/20);
end
end

