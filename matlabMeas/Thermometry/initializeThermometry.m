function [thermometer] = initializeThermometry(thermometerType)
% Initializing Thermometry variables in the workspace. Ensures that one can using drawing function
% to draw data as well as clear data before use. Returns arrays.
    if exist('time ','var')
        clear time;
    end

    if exist('temperature','var')
        clear temperature;
    end
    assignin('base','time',[]);
    assignin('base','temperature',[]);
    
    [ZL,ZU] = getZCoefficients(thermometerType);
    [lookUpTemp,lookUpRes] = getLookUpTables(thermometerType);
    chebychevCoefficients = getChebCoefficients(thermometerType);
    thermometer = cernoxThermom(ZL,ZU,chebychevCoefficients,lookUpTemp,lookUpRes);

end