function [deltaVal] = checkDeltaSign(startVal,stopVal,deltaVal)
    if startVal > stopVal && deltaVal > 0
        deltaVal = -1*deltaVal;
    elseif startVal < stopVal && deltaVal < 0
        deltaVal = -1*deltaVal;
    end
end

