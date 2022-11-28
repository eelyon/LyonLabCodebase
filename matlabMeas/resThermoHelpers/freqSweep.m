function [] = freqSweep(lockIn, freq0, freqf, num)
    fvec = linspace(freq0, freqf, num);    
    tau = SR830queryTau(lockIn);
    waitTime = 12 * tau;
    
    for f = fvec
        SR830setFreq(lockIn,f);
        pause(waitTime);
    end

    for f = flip(fvec)
        SR830setFreq(lockIn,f);
        pause(waitTime);
    end
end