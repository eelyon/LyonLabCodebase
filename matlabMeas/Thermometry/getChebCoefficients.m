function [coefficients] = getChebCoefficients(thermometerType)
    if strcmp(thermometerType,'939801')
        coefficients = [5.649284,-6.496949,2.795808,-0.969290,.271303,-0.056705,.005340,.002012,-.001516,.00707];
    else
        disp('Your thermometer calibration does not exist!');
    end
end
