%% This script characterizes the transfer of electrons as a function of constant IDC bias

% Characterize constant IDC bias 
IDCVoltArr = [-3 -2 -1 -0.75 -0.5 0 0.1];
doorAWG(VpulsSig,VpulsAgi,100,500,0,'ms') 
pause(1)

for IDCVolt = IDCVoltArr
    sigDACRampVoltage(DAC,[IDCPFPort,IDCNFPort],[IDCVolt,IDCVolt],10000);
    pause(10);
    set33220Trigger(VpulsAgi,'BUS');
    pause(3);

    % ST measurement after opening doors
    sweepType = 'ST';
    
    start = sigDACQueryVoltage(DAC,16);
    deltaParam = -0.05;
    stop = -0.5;

    timeBetweenPoints = 0.5;
    repeat = 5;
    readSR830 = {VmeasC,VmeasE};
    device = DAC;
    ports = {StmCPort,StmEPort};
    doBackAndForth = 1;

    sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth);
    pause(0.1)
end
