%% This script characterizes the door openning voltage of the emitter

doorEOpen = [-5 -1.5 -0.5 -0.1 0 0.1:0.1:0.3];
doorAWG(VpulsSig,VpulsAgi,100,500,0,'ms') 
pause(1)

for doorVolt = doorEOpen
    sigDACRampVoltage(sigDAC,DoorEOpenPort,doorVolt,10000);
    pause(10);
    fprintf(VpulsAgi, 'TRIG:SOUR BUS; *TRG');  % to open the doors
    pause(3);

    % ST measurement after opening doors
    sweepType = {'ST'};
    
    start = sigDACQueryVoltage(sigDAC,16);
    deltaParam = -0.05;
    stop = -0.5;

    timeBetweenPoints = 0.5;
    repeat = 5;
    readSR830 = {VmeasE};
    device = DAC;
    ports = {16};
    doBackAndForth = 1;

    sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);
    pause(0.1)
end