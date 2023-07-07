%% Test Twiddle Sense

start = 0.004;
deltaParam = 0.016;
stop = 0.1;
timeBetweenPoints = 30;
repeat = 5;
sweep1DMeasSR830({'TWD'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},VmeasE,{'Amp'},0,VmeasC);