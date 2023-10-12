DCConfigDAC(DAC,'Emitting',1000)
set33220VoltageOffset(VdoorModE,-1);
set33220VoltageOffset(VtwiddleE,-1);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{9},0);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0);

start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0);

start = 0;
deltaParam = -0.02;
stop = -0.4;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);

start = 0;
deltaParam = -0.02;
stop = -0.4;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,20,{VmeasC},DAC,{17},1);

start = 0;
deltaParam = -0.02;
stop = 0.4;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);


start = 0.1;
deltaParam = -0.02;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},0);



start = 0;
deltaParam = -0.05;
stop = -1;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{23},0);







start = -1;
deltaParam = -0.02;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},0);

start = -0.95;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleC,{5},1);

start = -1;
deltaParam = -0.05;
stop = 0;
sweep1DMeasSR830({'SEN'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{16},0);


start = -0.3;
deltaParam = -0.025;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,20,{VmeasC},VdoorModE,{5},0);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start = 0;
deltaParam = -0.025;
stop = -0.3;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,10,{VmeasC},DAC,{4},0);


doorV = [-1:0.1:-0.1 -0.1:-0.1:-1];

for i =1:length(doorV)
    start = doorV(i);
    deltaParam = -0.05;
    stop = doorV(i+1);
    sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.1,10,{VmeasC},VdoorModE,{5},0);
    
    pause(5)

    start = 0;
    deltaParam = -0.02;
    stop = 0.4;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);
    
    pause(5)

    start = 0;
    deltaParam = -0.02;
    stop = 0.4;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasC},VtwiddleE,{5},1);
end



