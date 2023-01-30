%% This function is meant for sweeping frequency and voltage

sweepTypes = {'Freq', 'ST'};

starts = {10000, 0};
stops = {1000, 1};
deltaParams = {1000, 0.1};
timeBetweenPoints = 0.5;
repeat = 10;
readSR830 = SR830;
devices = {SR830,SR830};
portss = {{'Freq'}, {'1'}};

sweep2DMeasSR830_Func(sweepTypes, starts, stops, deltaParams, devices, portss, timeBetweenPoints,repeat,readSR830);