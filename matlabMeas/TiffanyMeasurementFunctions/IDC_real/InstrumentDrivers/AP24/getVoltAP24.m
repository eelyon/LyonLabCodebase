function [value] = getVoltAP24( AP24, Port )
    fprintf(AP24,['CH ' num2str(Port)]);
    value = str2double(query(AP24,'VOLT?'));
end

