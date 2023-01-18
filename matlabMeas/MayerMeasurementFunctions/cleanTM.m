if getVal(DAC,Top100Port) > 0
    sweepMeasSR830_Func('Pair',getVal(DAC,Top100Port),-.5,-0.25,.3,10,SR830,DAC,{4,2},0);
    sweepMeasSR830_Func('Pair',getVal(DAC,Top100Port),-2,-0.25,.3,10,SR830,DAC,{4,2},1);
else
    pairMags = sweepMeasSR830_Func('Pair',-.5,-3-DPBias,-0.25,.3,10,SR830,DAC,{4,2},1);
end

sweepMeasSR830_Func('ST',0,-0.3,-0.025,.1,5,SR830,DAC,{8},1);
rampVal(DAC,Res100Port,getVal(DAC,Res100Port),1.5,.05,.3);
DoorMags = sweepMeasSR830_Func('Door',getVal(DAC,Door100Port),.25,0.25,.05,10,SR830,DAC,{1},0);
disp('Done sweeping Door');
sweepMeasSR830_Func('ST',0,-0.3,-0.025,.1,5,SR830,DAC,{8},1);
sweepMeasSR830_Func('Door',getVal(DAC,Door100Port),-2,-0.25,.05,10,SR830,DAC,{1},0);