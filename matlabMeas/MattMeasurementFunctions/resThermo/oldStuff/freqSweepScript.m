%% This function is meant for sweeping frequency

sweepType = {'Freq'};

start = 1000;
stop = 10000;
deltaParam = 1000;
timeBetweenPoints = 0.3;
repeat = 10;
readSR830 = {SR830};
device = SR830;
ports = {'Freq'};
doBackAndForth = 1;

sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);