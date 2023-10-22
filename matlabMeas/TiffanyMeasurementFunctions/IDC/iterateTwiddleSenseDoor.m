


start = getVal(DAC,DoorEInPort);
deltaParam = 0.01;
deltaSweep = 0.05;
stop = 1;
signage = sign(stop-start);
numVoltages = abs(stop-start)/deltaSweep;
for i = 1:numVoltages
    currentStart = start + signage*(i-1)*deltaSweep;
    currentStop = start + signage*i*deltaSweep;
    sweep1DMeasSR830({'TWW'},currentStart,currentStop,deltaParam,0.05,5,{VmeasE},DAC,{TwiddleEPort},0);
    sweep1DMeasSR830({'SEN'},currentStart,currentStop,deltaParam,0.05,5,{VmeasE},DAC,{SenseEPort},0);
    sweep1DMeasSR830({'Door'},currentStart,currentStop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEInPort},0);

end
