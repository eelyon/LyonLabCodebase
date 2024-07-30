interleavedRamp([controlDAC,supplyDAC],[22,9],[-1,0.5],10,0.05) %% CCD1 to CCD2
delay(1);
interleavedRamp([controlDAC,controlDAC],[22,10],[0.5,-1],10,0.05) %% CCD3 to CCD1
delay(1);
interleavedRamp([supplyDAC,controlDAC],[9,10],[-1,0.5],10,0.05) %% CCD3 to CCD1
% interleavedRamp([controlDAC,supplyDAC],[10,9],[-1,0],10,0.05) %% CCD3 to CCD2
% interleavedRamp([controlDAC,controlDAC],[22,10],[-1,0],10,0.05) %% CCD1 to CCD3
% interleavedRamp([controlDAC,supplyDAC],[22,9],[0,-1],10,0.05) %% CCD1 to CCD2
% rampVal(controlDAC,10,0,-0.5,0.05,0.05);rampVal(controlDAC,22,0,-0.4,0.05,0.05);