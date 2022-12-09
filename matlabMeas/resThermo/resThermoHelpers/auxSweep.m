function [output] = auxSweep(lockIn, auxNum, v0, vf, num, avgs, timeMult)
    initspace = (v0-vf) / num;
    vvec = [0:initspace:v0, v0-initspace:-initspace:vf+initspace, vf:initspace:0];    
    bigWaitTime = 4 * timeMult;
    mesWaitTime = 0.5 * bigWaitTime;
    output = zeros(length(vvec), 3);
    invavgs = 1 / avgs;
    ind = 1;
    
    for v = vvec
        SR830setAuxOut(lockIn, auxNum, v);
        pause(bigWaitTime);
        output(ind, 1) = v;
        for throwaway = 1:1:avgs
            output(ind, 2) = output(ind, 2) + str2double(SR830queryX(lockIn)) * invavgs;
            output(ind, 3) = output(ind, 3) + str2double(SR830queryY(lockIn)) * invavgs;
            pause(mesWaitTime);
        end
        ind = ind + 1;
    end
end