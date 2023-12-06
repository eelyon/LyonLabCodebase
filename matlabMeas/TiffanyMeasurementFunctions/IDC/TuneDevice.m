%% clean device and make sure emission is pretty consistant 

num = 3;  % number of times to test cleaning procedure
BackingMetalVolt = -1;
numFlash = 1;

for i = 1:num
    DCConfigDAC(DAC,'Zero',1000);
    sigDACSetVoltage(DAC,TopMetalPort,7);
    pause(11)
    sigDACSetVoltage(DAC,TopMetalPort,BackingMetalVolt);
    pause(1)
    DCConfigDAC(DAC,'Emitting',1000);
    pause(2)
    
    for j = 1:numFlash
        send33220Trigger(Filament)
        pause(3)
    end
    
    start = 0;
    deltaParam = -0.025;
    stop = -0.5;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
end

%% Do IDC tuning scans
doorAgi(VpulsAgi,VpulsAgi2,20,500,'ms');
IDCvoltage = [-1.5 -1 -1.25 -0.75 -2];
timeBetweenPoints = 0.05;
repeat = 5;
waittime = 11;

for i= IDCvoltage
    startingEPinch = -0.2;
    DCConfigDAC(DAC,'Transferring1',10000);pause(waittime)
    DCConfigDAC(DAC,'Transferring2',1000);pause(5)
    DCConfigDAC(DAC,'Transfer',10000);pause(waittime)
    
    send33220Trigger(VpulsAgi)
    pause(3)

    %% single VmeasC
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.005;
    stop = start-0.15;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);
    
    %% single VmeasE
    deltaParam = -0.01;
    stop = -0.3;
    sweep1DMeasSR830({'ST'},0,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
    
    DCConfigDAC(DAC,'TransferringBack',10000);pause(waittime)
    DCConfigDAC(DAC,'TransferBack1',10000);pause(waittime)
    DCConfigDAC(DAC,'TransferBack2',10000);pause(waittime)

    sigDACRampVoltage(DAC,[8,12],[i,i],10000);pause(3)
    rampVal(DAC,21,-2.5,-0.6,0.01,0.03)
    pause(6)
    
    rampVal(DAC,23,-0.1,-1,-0.01,0.03) % closes emitter door for scan
    pause(3)

    %% single VmeasE
    deltaParam = -0.01;
    stop = -0.3;
    sweep1DMeasSR830({'ST'},0,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
    
    DCConfigDAC(DAC,'Emitting',1000);
    pause(2)

    start = 0;
    deltaParam = -0.01;
    stop = -0.2;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
end


%% TF delta characterization
doorAgi(VpulsAgi,VpulsAgi2,50,500,'ms');
TFCvoltage = 1.5; %[1.5 1.7 1.2 0.95 0.8 0.7];

for i= TFCvoltage
    num = 3;
    BackingMetalVolt = -1;
    numFlash = 1;

    startingEPinch = 0.3;
    DCConfigDAC(DAC,'Transferring1',10000);pause(10)
    DCConfigDAC(DAC,'Transferring2',1000);pause(5)
    DCConfigDAC(DAC,'Transfer',10000);pause(10)
    
    STCvolt = i+0.8;
    TopCVolt = STCvolt - 0.7;
    sigDACRampVoltage(DAC,[3,22,2,20,18],[i,STCvolt,STCvolt,STCvolt,TopCVolt],10000);
    pause(10)
    
    input('correct?');

    send33220Trigger(VpulsAgi)
    pause(3)

    %% single VmeasC
    start = sigDACQueryVoltage(DAC,20);
    deltaParam = -0.02;
    stop = start-0.2;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{20},1);
    
    %% single VmeasE
    deltaParam = -0.02;
    stop = -0.15;
    sweep1DMeasSR830({'ST'},0,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
    
    DCConfigDAC(DAC,'TransferringBack',10000);pause(10)
    DCConfigDAC(DAC,'TransferBack1',10000);pause(10)
    DCConfigDAC(DAC,'TransferBack2',10000);pause(10)
    
    rampVal(DAC,21,-1.2,10000);  % opens collector door, since emitter door is open by default
    pause(15)
    
    sigDACRampVoltage(DAC,23,-1,10000);  % closes emitter door for scan
    pause(10)

    %% single VmeasE
    deltaParam = -0.02;
    stop = -0.2;
    sweep1DMeasSR830({'ST'},0,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
    
    %% CLEAN

    DCConfigDAC(DAC,'Zero',1000);
    sigDACSetVoltage(DAC,TopMetalPort,7);
    pause(10)
    sigDACSetVoltage(DAC,TopMetalPort,BackingMetalVolt);
    pause(1)
    DCConfigDAC(DAC,'Emitting',1000);
    pause(2)
    
    for j = 1:numFlash
        send33220Trigger(Filament)
        pause(3)
    end

    start = 0;
    deltaParam = -0.02;
    stop = -0.2;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasE},DAC,{16},1);
end

% testing
DCConfigDAC(DAC,'Emitting',1000)
send33220Trigger(Filament)
pause(1)
send33220Trigger(Filament)
pause(1)

DCConfigDAC(DAC,'Transferring1',10000);pause(10)
DCConfigDAC(DAC,'Transferring2',1000);pause(5)
DCConfigDAC(DAC,'Transfer',10000);pause(10)

send33220Trigger(VpulsAgi)
pause(1)
send33220Trigger(VpulsAgi)
pause(1)

DCConfigDAC(DAC,'TransferringBack',10000);pause(10)
DCConfigDAC(DAC,'TransferBack1',10000);pause(10)
DCConfigDAC(DAC,'TransferBack2',10000);pause(10)