%% This script sweeps the voltage of the IDCs

sigDACSetVoltage(DAC,12,0);

sweepType = {'IDC'};
    
start = 0;
deltaParam = 5;
stop = 30;

timeBetweenPoints = 50;
repeat = 10;
readSR830 = {VmeasE};
device = DAC;
ports = {8};
doBackAndForth = 1;

sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);