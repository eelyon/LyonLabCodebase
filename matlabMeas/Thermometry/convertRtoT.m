function [tempInK] = convertRtoT(resistance,thermometerType)
    coefficients = getChebCoefficients(thermometerType);
    tempInK = 0;
    for i = 1:length(coefficients)
        cheb = calcChebychevs(i-1,resistance,coefficients(i));
        tempInK = tempInK + cheb;
    end

end