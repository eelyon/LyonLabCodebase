y3dB = yDat(1)-3;
for i  = 1:length(xDat)
    if yDat(i) < y3dB
        start3dB = i;
        break
    end
end

for i = length(xDat):-1:1
    if yDat(i) < y3dB
        end3dB = i;
        break
    end
end

FWHM = xDat(end3dB) - xDat(start3dB);
[minVal,resIndex] = min(yDat);
resFreq = xDat(resIndex);

Q = resFreq/FWHM