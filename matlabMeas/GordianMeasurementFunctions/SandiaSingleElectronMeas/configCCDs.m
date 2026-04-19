ccdDefine(controlDAC,'A',pinout.phi_h1_1.port,pinout.phi_h1_2.port,pinout.phi_h1_3.port);
ccdDefine(controlDAC,'B',pinout.phi_h2_1.port,pinout.phi_h2_2.port,pinout.phi_h2_3.port);
ccdDefine(supplyDAC,'C',pinout.phi_v1_2.port,pinout.phi_v1_3.port,pinout.phi_v1_1.port);
ccdDefine(supplyDAC,'D',pinout.phi_v2_1.port,pinout.phi_v2_2.port,pinout.phi_v2_3.port);

ccdAmplitude(controlDAC,'A','ALL',2.0,-1.0);
ccdAmplitude(controlDAC,'B','ALL',2.0,-1.0);
ccdAmplitude(supplyDAC,'C','ALL',2.0,-1.0);
ccdAmplitude(supplyDAC,'D','ALL',2.0,-1.0);

ccdDwellPerPhase(controlDAC,'A','ALL',0);
ccdDwellPerPhase(controlDAC,'B','ALL',0);
ccdDwellPerPhase(supplyDAC,'C','ALL',0);
ccdDwellPerPhase(supplyDAC,'D','ALL',0);

ccdIntermediateStep(controlDAC,'A','ALL','HALF')
ccdIntermediateStep(controlDAC,'B','ALL','HALF');
ccdIntermediateStep(supplyDAC,'C','ALL','HALF');
ccdIntermediateStep(supplyDAC,'D','ALL','HALF');