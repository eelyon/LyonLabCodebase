send33220Trigger(VpulsAgi)
pause(3)
send33220Trigger(VpulsAgi)
pause(3) 

start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.005;
stop = start-0.15;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);

pause(5)

start = 0;
deltaParam = -0.005;
stop = -0.15;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);