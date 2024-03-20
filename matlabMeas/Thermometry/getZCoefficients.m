function [ZL,ZU] = getZCoefficients(thermometerType)
    if strcmp(thermometerType,'X117656')
            ZL = 2.68491328511;
            ZU = 3.88972245339;

    elseif strcmp(thermometerType,'X189328')  % 1.4 to 14K
            ZL = 2.84334238169;
            ZU = 4.14866501287;
    elseif strcmp(thermometerType,'X189327')
            ZL = 2.87835571995;
            ZU = 4.2450743341;
    else
        disp('Your thermometer calibration does not exist!');
    end
end

