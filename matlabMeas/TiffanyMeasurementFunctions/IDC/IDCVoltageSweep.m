%% This script sweeps the voltage of the IDCs

sigDACSetVoltage(DAC,12,0);

sweepType = {'IDC'};
    
start = 0;
deltaParam = 1;  
stop = 8;  % 30;

timeBetweenPoints = 10;
repeat = 5;
readSR830 = {VmeasE};
device = DAC; % SIM900;
ports = {8};  % other port
doBackAndForth = 1;

sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);