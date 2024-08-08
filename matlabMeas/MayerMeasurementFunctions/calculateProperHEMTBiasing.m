function [inputHEMTGate,inputHEMTDrain,cascodeGate,cascodeDrain,emitterFollowerDrain,emitterFollowerSource] = calculateProperHEMTBiasing(currentSourceVoltage)
% We want to properly bias the HEMT. All the values should be calculated
% relative to the current source voltage. 

% Voltages to aim for: gate = -0.6V source; drain = 1.1 to 1.2V above gate.

inputHEMTGate = currentSourceVoltage - 0.53;
inputHEMTDrain = inputHEMTGate + 0.9;
cascodeGate = inputHEMTDrain - 0.53;
cascodeDrain = cascodeGate+ 0.9;

emitterFollowerDrain = cascodeDrain + 0.9;
emitterFollowerSource = cascodeDrain +0.53;

end

