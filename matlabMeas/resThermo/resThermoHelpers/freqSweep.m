function [output] = freqSweep(lockIn, freq0, freqf, num, avgs, timeMult)
    fvec = [linspace(freq0, freqf, num), linspace(freqf, freq0, num)];
    tau = SR830queryTau(lockIn);
    bigWaitTime = 4 * timeMult;
    mesWaitTime = 0.5 * bigWaitTime;
    output = zeros(length(fvec), 3);
    invavgs = 1 / avgs;
    ind = 1;
    
    for f = fvec
        SR830setFreq(lockIn,f);
        pause(bigWaitTime);
        output(ind, 1) = f;
        for throwaway = 1:1:avgs
            output(ind, 2) = output(ind, 2) + str2double(SR830queryX(lockIn)) * invavgs;
            output(ind, 3) = output(ind, 3) + str2double(SR830queryY(lockIn)) * invavgs;
            pause(mesWaitTime);
        end
        ind = ind + 1;
    end
end