[inputHEMTGate,inputHEMTDrain,cascodeGate,cascodeDrain,emitterFollowerDrain,emitterFollowerSource] =  calculateProperHEMTBiasing(.558);

setVal(supplyDAC,16,cascodeGate);
setVal(supplyDAC,14,cascodeDrain+1.2);
setVal(supplyDAC,15,emitterFollowerDrain);

% setVal(supplyDAC,23,cascodeGate);
% setVal(supplyDAC,24,cascodeDrain+1.2);
% setVal(supplyDAC,13,emitterFollowerDrain);