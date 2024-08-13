startShield = 0.2;
stopShield = -3;
shieldStep = 0.2;

for n = 1:1
    [avgMag,avgReal,avgImag,stdReal,stdImag] = sweep1DMeasSR830Fast({'Shield'},startShield,stopShield,shieldStep,3,5,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1);
    mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
    delta = max(mag) - min(mag); % Calc. change in signal
    numEs = calcNumElectrons(capacitance,delta,gain); % Calc. tot. no. of electrons
    display(numEs,'numEs'); fprintf(['\nstdev = ',num2str(sqrt(stdReal(1).^2+stdImag(1).^2)),'\n'])
end

function [nE] = calcNumElectrons(capacitance,Volts,gain)
% Calc. electron number from measured voltage
    nE = (capacitance*2*sqrt(2)*Volts)/(1.602e-19*gain);
end

function [corrMag] = correctedMag(real,imag)
% Correct measured magnitude by background signal
    corrReal = real - real(length(real)); % Subtract background from Re
    corrImag = imag - imag(length(imag)); % Subtract background from Imag
    corrMag = sqrt(corrReal.^2 + corrImag.^2); % Calc. magnitude
end