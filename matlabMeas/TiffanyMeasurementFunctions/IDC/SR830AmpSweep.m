voltages = 0.1:0.1:0.5; 

for i=voltages
    SR830setAmplitude(VmeasE,i);
    start = 0;
    deltaParam = 0.025;
    stop = -0.35;
    timeBetweenPoints = 0.05;
    repeat = 5;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{17},1); 
end

Offsetvoltages= 0:-0.025:-0.5;

for i=voltages
    Agilent33220A(VdoorModE, i) 

end