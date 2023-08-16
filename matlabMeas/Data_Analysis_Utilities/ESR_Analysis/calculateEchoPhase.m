function [phaseInDegrees] = calculateEchoPhase(IDat,QDat)
    magI = sum(IDat.^2);
    magQ = sum(QDat.^2);
    phaseInDegrees = atan(magQ/magI)*180/pi;
end

