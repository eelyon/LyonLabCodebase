function CIErr = calculateConfidenceInterval(CIVector,arr,numRepeats)
    CIErr = (std(arr)/sqrt(numRepeats).*CIVector)*2;
end
