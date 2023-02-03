sweepType = {'ST'};
start = 0;
stop = -0.5;
deltaParam = 0.05;
timeBetweenPoints = 1;
readSR830 = {VmeasE};
device =  DAC;
repeat = 10;
ports = {3};
doBackAndForth = 1;

sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);