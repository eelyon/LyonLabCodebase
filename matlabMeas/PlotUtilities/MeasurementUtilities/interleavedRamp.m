function [] = interleavedRamp(devices,ports,stop,numSteps,waitTime)
% Function interleaves sweeps of parameters. Devices, ports, and stop must
% be an array of identical size. WaitTime is in seconds.
starts = [];
voltages = {};

for i = 1:length(ports)
    startVal = getVal(devices(i),ports(i));
    delta = (stop(i) - startVal)/numSteps;
    starts(i) = startVal;
    voltages{i} = starts(i):delta:stop(i);
end

for vParam = 1:length(voltages{1})
    for portParam = 1:length(ports)
        % voltages{portParam}(vParam)
        setVal(devices(portParam),ports(portParam),voltages{portParam}(vParam));
        pause(waitTime);
    end
end

end

