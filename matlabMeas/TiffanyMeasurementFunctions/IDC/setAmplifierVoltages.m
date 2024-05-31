% assuming 15uA from current mirror
VccAmp = 7;
Vbb = 24;
VccFollower = 13;

% ramp amplifier voltages on
rampVal(supplyDAC,VccAmp,0,2,0.05,0.025);
rampVal(supplyDAC,VccFollower,0,2,0.05,0.025);
rampVal(supplyDAC,Vbb,0,1.4,0.05,0.025);

rampVal(supplyDAC,VccAmp,2,6.75,0.05,0.025);
rampVal(supplyDAC,VccFollower,2,2.4,0.05,0.025);

% ramp amplifier voltages off
startVccAmp = getVal(supplyDAC,VccAmp);
startVbb = getVal(supplyDAC,startVbb);
startVccFollower = getVal(supplyDAC,startVccFollower);

rampVal(supplyDAC,VccAmp,startVccAmp,2,0.05,0.025);
rampVal(supplyDAC,VccFollower,startVccFollower,2,0.05,0.025);
rampVal(supplyDAC,Vbb,startVbb,0,0.05,0.025);

rampVal(supplyDAC,VccAmp,2,0,0.05,0.025);
rampVal(supplyDAC,VccFollower,2,0,0.05,0.025);