function [coefficients] = getChebCoefficients(thermometerType)
    if strcmp(thermometerType,'939801')
        coefficients = [5.649284,-6.496949,2.795808,-0.969290,.271303,-0.056705,.005340,.002012,-.001516,.00707];
    elseif strcmp(thermometerType,'X189328') % 1.4K to 14K
        coefficients = [5.571487,-6.388558,2.750689,-0.955339,.270645,-0.059402,.007658,.000646,-0.001037];
    else
        disp('Your thermometer calibration does not exist!');
    end
end
