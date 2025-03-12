function [coefficients] = getChebCoefficients(thermometerType)
    if strcmp(thermometerType,'X117656')
        coefficients = [5.649284,-6.496949,2.795808,-0.969290,.271303,-0.056705,.005340,.002012,-.001516,.00707];
    elseif strcmp(thermometerType,'X189328') % 1.4K to 14K
        coefficients = [5.571487,-6.388558,2.750689,-0.955339,.270645,-0.059402,.007658,.000646,-0.001037];
    elseif strcmp(thermometerType,'X204446') % 1.4K to 14K
        coefficients = [5.487638,-6.308681,2.792266,-1.019812,0.312035,-0.077432,0.013465,-0.000482,-0.001030];
    elseif strcmp(thermometerType,'X189327')
        coefficients = [5.542940,-6.362573,2.765561,-0.976236,0.282996,-0.064305,0.009030,0.000457,-0.001173];
    else
        disp('Your thermometer calibration does not exist!');
    end
end
