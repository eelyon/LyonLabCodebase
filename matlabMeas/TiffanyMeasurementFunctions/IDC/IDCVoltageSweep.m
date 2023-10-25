%% This script sweeps the voltage of the IDCs

sweepType = {'IDC'};
    
start = 0;
deltaParam = 5;  
stop = 20;  % gets doubled to 40, hard coded in sweep1D to apply to 4,5 ports 

timeBetweenPoints = 40;
repeat = 10;
readSR830 = {VmeasE};
device = IDC;
ports = {3};  
doBackAndForth = 1;

sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);

timeBetweenPoints = 0.05;
repeat = 5;

