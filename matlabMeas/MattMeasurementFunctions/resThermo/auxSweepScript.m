%% This function is meant for sweeping voltage

sweepType = {'ST'};

start = 0.1;
stop = -0.5;
deltaParam = 0.05;
timeBetweenPoints = 0.3;
repeat = 10;
readSR830 = {SR830};
device = DAC;
ports = {3};
doBackAndForth = 1;

sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);