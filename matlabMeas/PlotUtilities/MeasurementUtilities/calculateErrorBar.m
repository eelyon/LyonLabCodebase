function [err] = calculateErrorBar(errorType,CIVector,vector,repeat)
    if strcmp(errorType,'CI')
        verr = calculateConfidenceInterval(CIVector,vector,repeat);
        err = verr(2);
    else
        err = std(vector);
    end
end
