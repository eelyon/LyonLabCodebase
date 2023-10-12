tStart = tic;
wait = 15;
numTrig = 3;

sweepType = 'ST';
timeBetweenPoints = 0.05;
repeat = 5;
readSR830 = {VmeasC,VmeasE};
device = DAC;
ports = {StmCPort,StmEPort};
doBackAndForth = 1;


% Transfer Electrons Configuration
DCConfigDAC_ST(DAC,'Transferring',10000);
pause(wait);
DCConfigDAC_ST(DAC,'Transfer',10000);
pause(wait);

% % Sweep Metal Negative
% SweepTopMetal(DAC,VmeasE,VmeasC,'TE',TimeInd);

% STM scan, pinch off
%% BEFORE TAUE     
start = sigDACQueryVoltage(DAC,16);
deltaParam = -0.05;
stop = -0.3;
configName = 'afterEmission';
sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);

% open door
doorAWG(VpulsSig,VpulsAgi,15,15,0,'ms')
pause(5)
send33220Trigger(VpulsAgi)
pause(1)
send33220Trigger(VpulsAgi)

% STM scan, pinch off
%% AFTER TAUE
deltaParam = -0.02;
stop = -0.3;
configName = 'AfterTauE';
sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);

% Transferring Back electrons to emitter
DCConfigDAC_ST(DAC,'TransferringBack',10000);
pause(wait)
DCConfigDAC_ST(DAC,'TransferBack',10000);
pause(wait)

doorAWG(VpulsSig,VpulsAgi,5,1,0,'ms')
pause(5)

for i = 1:numTrig
    set33220Trigger(VpulsAgi,'BUS');  % to open the doors
    pause(1)
end

sigDACRampVoltage(DAC,18,-1.7,10000);
pause(wait)

% open door to transfer back electrons to emitter 
for i = 1:numTrig
    set33220Trigger(VpulsAgi,'BUS');  % to open the doors
    pause(1)
end

% STM scan, pinch off
%% AfterTransferBack
deltaParam = -0.05;
stop = -0.5;
configName = 'AfterTransferBack';
sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);

% Transferring electrons
DCConfigDAC_ST(DAC,'Transferring',10000);
pause(wait);
DCConfigDAC_ST(DAC,'Transfer',10000);
pause(wait);

% final STM scan, pinch off
%% AfterTransferring
deltaParam = -0.025;
stop = -0.4;
configName = 'AfterTransferring';
sweep1DMeasDUALSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth,configName);
tStart = tic;
sigDACRampVoltage(DAC,1,-2,20000)
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));

