function [] = compensateParasitics(device,doorDevice,twiddleDevice,startPhase,stopPhase,phaseStepSize,startAmp,stopAmp,ampStepSize,isCurrentMeas)

turnDevOn(doorDevice);
turnDevOn(twiddleDevice);

if phaseStepSize < .001
    disp('Minimum phase step size is 1e-3! Exiting compensation function!')
    return;
end

flush(device.client);
startPhaseStepExp = determineExponent(phaseStepSize);
phaseArr = logspace(startPhaseStepExp,-3,startPhaseStepExp+4);

startAmpStepExp = determineExponent(ampStepSize);
ampStepSizeArr = logspace(startAmpStepExp,-5,startAmpStepExp+6);
ampStepSizeArr = ampStepSizeArr(1:length(ampStepSizeArr)-1);
if length(ampStepSizeArr) < length(phaseArr)
    totalIterations = length(ampStepSizeArr);

else
    totalIterations = length(phaseArr);
end

for i = 1:totalIterations
    if i ~= 1
        phaseRange = phaseArr(i)*30;
        startPhase = optPhase - phaseRange/2;
        stopPhase = optPhase + phaseRange/2;

        ampRange = ampStepSizeArr(i)*30;
        startAmp = optAmp - ampRange/2;
        stopAmp = optAmp + ampRange/2;
    end
    %% Find best phase first
    optPhase = sweepOptimize(device, doorDevice, phaseArr(i), startPhase, stopPhase, 'Phase', isCurrentMeas);
    setVal(doorDevice,3,optPhase);
    delay(0.5);
    device.adjustSensitivity(device.SR830queryY(),isCurrentMeas);
    %
    optAmp = sweepOptimize(device, doorDevice, ampStepSizeArr(i), startAmp, stopAmp, 'Amp', isCurrentMeas);
    setVal(doorDevice,4,optAmp);

    delay(0.5);
    device.adjustSensitivity(device.SR830queryY(),isCurrentMeas);
end


delay(1);
fprintf(['(real,imag) = (', num2str(SR830queryX(device)*1e6),'uV,' num2str(SR830queryY(device)*1e6), 'uV) \n']);

end

function exponent = determineExponent(num)
numStr = sprintf('%10e',num);
splitArr = split(numStr,'e');
exponent = splitArr(2);
exponent = exponent{1};
exponent = str2double(exponent);
end