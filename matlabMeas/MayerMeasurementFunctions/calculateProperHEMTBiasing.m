function [inputHEMTGate,inputHEMTDrain,cascodeGate,cascodeDrain,emitterFollowerDrain,emitterFollowerSource] = calculateProperHEMTBiasing(currentSourceVoltage)
% We want to properly bias the HEMT. All the values should be calculated
% relative to the current source voltage. 

% Voltages to aim for: gate = -0.6V source; drain = 1.1 to 1.2V above gate.

inputHEMTGate = currentSourceVoltage - 0.4;
inputHEMTDrain = inputHEMTGate + 1.1;
cascodeGate = inputHEMTDrain - 0.4;
cascodeDrain = cascodeGate+ 1.1;

emitterFollowerDrain = cascodeDrain + 1.1;
emitterFollowerSource = cascodeDrain +0.6;

end

