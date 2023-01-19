currentDPDelta = getVal(DAC,Dot100Port) - getVal(DAC,Top100Port);
finalDPDelta = -2.25;
delta = -0.5;

startDPDelta = getVal(DAC,Dot100Port);
deltas = startDPDelta:delta:finalDPDelta;

for DPVoltages = deltas
    
    sweepMeasSR830_Func('Pair',-0.5,-2,-0.25,.3,10,SR830,DAC,{Top100Port,Dot100Port},1);
    sweepMeasSR830_Func('ST',0,-0.05,-0.005,.3,40,SR830,DAC,{8},1);
    rampVal(DAC,Dot100Port,DPVoltages,DPVoltages+delta,-.025,.01);
end