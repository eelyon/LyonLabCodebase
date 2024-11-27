function [optimalValue] = sweepOptimize(device, doorDevice, stepSize, start, stop, type, isCurrentMeas)
N = 1:length(stepSize);
for i = N
    delta = stepSize(i);
    
    if strcmp(type,'Phase')
        if delta < 1e-3
            display("Phase delta is too small");
            delta = 0.1;
            stop = start + delta*15;
        end
        SR830setSensitivity(device,26)

        setVal(doorDevice,3,start);
        delay(0.5)
        device.adjustSensitivity(device.SR830queryY(),isCurrentMeas)
        delay(0.5)

        mags = sweep1DMeasSR830({'PHAS'},start,stop,delta,1,5,{device},doorDevice,{3},0,1);
    else
        if delta < 0.0001
            display("Amplitude delta is too small");
            delta = .00001;
            stop = start + delta*15;
        end
        SR830setSensitivity(device,26)
        setVal(doorDevice,4,start);
        delay(0.5)
        device.adjustSensitivity(device.SR830queryY(),isCurrentMeas)
        mags = sweep1DMeasSR830({'Vpp'},start,stop,delta,1,5,{device},doorDevice,{4},0,1);
    end
end

xlist = start:delta:stop;
minimumValue = xlist(find(mags==min(mags)));
minimumValue = minimumValue(1);
if minimumValue > 350 || minimumValue < -350  % hard to search in this region, so exclude it
    nextMin = min(setdiff(mags,min(mags)));
    minimumValue = xlist(find(mags==nextMin));
end

if minimumValue == stop && strcmp(type,'Amp')
    delta = stop-start;
    newStart = stop;
    newStop = stop + delta;
    optimalValue = sweepOptimize(device, doorDevice, stepSize, newStart,newStop, type, isCurrentMeas);
elseif minimumValue == start && strcmp(type,'Amp')
    delta = stop - start;
    newStart = start - delta;
    newStop = start;
    optimalValue = sweepOptimize(device, doorDevice, stepSize, newStart,newStop, type, isCurrentMeas);
else
    optimalValue = minimumValue;
end
if strcmp(type,'Phase')
    optimalValue = minimumValue;
end

end
