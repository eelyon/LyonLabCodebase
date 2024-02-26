%% Transfer Measurement Procedure

% IDC sweep to make sure there's enough helium
IDCVoltageSweep;

% emit electrons and measure
sigDACRampVoltage(DAC,5,-1.3,1000)
DCConfigDAC(DAC,'Emitting',1000);

start = 0;
deltaParam = 0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

start = 0;
deltaParam = 0.02;
stop = -0.4;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% Transfer
DCConfigDAC(DAC,'Transferring1',8000);
pause(9)

DCConfigDAC(DAC,'Transferring2',8000);
pause(9)

DCConfigDAC(DAC,'Transfer',8000);
pause(9)

% Door Sweep
sigDACRampVoltage(DAC,DoorCClosePort,1,1000);

start = sigDACQueryVoltage(DAC,DoorEClosePort);
deltaParam = -0.02;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);

% push
sigDACRampVoltage(DAC,STOBiasEPort,-0.3,1000)
pause(7)
sigDACRampVoltage(DAC,StmEPort,-0.3,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasEPort,-0.3,1000)
pause(1)

sigDACRampVoltage(DAC,STOBiasEPort,-0.5,1000)
pause(3)
sigDACRampVoltage(DAC,StmEPort,-0.5,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasEPort,-0.5,1000)
pause(3)

sigDACRampVoltage(DAC,STOBiasEPort,0,1000)
pause(1)
sigDACRampVoltage(DAC,StmEPort,0,1000)
pause(1)
sigDACRampVoltage(DAC,STIBiasEPort,0,1000)
pause(1)

sigDACRampVoltage(DAC,DoorCClosePort,-1,1000);
sigDACRampVoltage(DAC,DoorEClosePort,-1,1000);

% After transfer sweeps check
start = sigDACQueryVoltage(DAC,StmCPort);
deltaParam = -0.02;
stop = start-0.4;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{StmCPort},1);

start = 0;
deltaParam = 0.05;
stop = -0.4;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% Transfer Back
DCConfigDAC(DAC,'TransferringBack',8000);
pause(9)

DCConfigDAC(DAC,'TransferBack1',8000);
pause(9)

DCConfigDAC(DAC,'TransferBack2',8000);
pause(9)

% begin twiddle sense, create pocket electrons
sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],[-1,-1,-1,-1],1000);
pause(5)
sigDACRampVoltage(DAC,STOBiasCPort,-1.2,1000)
pause(3)
sigDACRampVoltage(DAC,StmCPort,-1.2,1000)
pause(3)
sigDACRampVoltage(DAC,DoorCInPort,-2,1000)

sigDACRampVoltage(DAC,[STOBiasCPort,StmCPort],[-1,-1],1000)
pause(2)

doorOpenList = [500 100 1 0.5] ;
for i = doorOpenList
    % calibrate emitter twiddle sense and make sure no electrons
    sigDACRampVoltage(DAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEClosePort],[-0.8,0,0,-0.8],1000);
    pause(5)
    VtwiddleE.set33220Output(1)
    VdoorModE.set33220Output(1)
    SR830setTimeConstant(VmeasE,7);
    twdAmp = 0.3; 
    compensateParasitics(VmeasE,VdoorModE,-360,180,10,0.01,twdAmp/2,0.01,0)
    pause(2)

    SR830setTimeConstant(VmeasE,10);
    sweep1DMeasSR830({'TWW'},0,0.7,-0.02,3,2,{VmeasE},DAC,{TwiddleEPort},1,1);
    pause(5)
    
    sigDACRampVoltage(DAC,DoorEInPort,-0.8,1000);
    pause(2)
    sigDACRampVoltage(DAC,DoorEClosePort,0,1000);
    pause(1)

    % transfer electrons create pocket electrons
    sigDACRampVoltage(DAC,[DoorCInPort,TwiddleCPort,SenseCPort],[-1,-1,-1],1000); pause(5)
    sigDACRampVoltage(DAC,STOBiasCPort,-1.3,1000); pause(3)
    sigDACRampVoltage(DAC,StmCPort,-1.3,1000); pause(3)
    sigDACRampVoltage(DAC,DoorCInPort,-2,1000); pause(1)
    sigDACRampVoltage(DAC,[STOBiasCPort,StmCPort],[-1,-1],1000); pause(2)

%     start = sigDACQueryVoltage(DAC,DoorCClosePort);
%     deltaParam = 0.05;
%     stop = -0.5;
%     sweep1DMeasSR830({'Door'},start,stop,deltaParam,1,2,{VmeasE},DAC,{DoorCClosePort},0);
    
    % open door
    set5122Output(VpulsSig,1,1);                % turn outputs on
    set5122Output(VpulsSig,1,2);
    pause(1)
    doorSiglent(VpulsSig,i,i*2,0,'ms');
    fprintf(VpulsSig.client,'C1:BTWV MTRIG');
    pause(5)
%     sigDACRampVoltage(DAC,DoorCClosePort,-2,1000); pause(1)
%     sigDACRampVoltage(DAC,DoorEClosePort,-0.8,1000); pause(1)
    
    set5122Output(VpulsSig,0,1);                % turn outputs off 
    set5122Output(VpulsSig,0,2);      

    % check for electrons
    sweep1DMeasSR830({'TWW'},0,1,-0.02,3,2,{VmeasE},DAC,{TwiddleEPort},1,1);
    
    % throw away electrons into reservoir
    VtwiddleE.set33220Output(0)
    VdoorModE.set33220Output(0)
    Vopen = 0;
    Vclose = -0.7;
    cleanElectrons(DAC, DoorEInPort,SenseEPort,TwiddleEPort,Vopen,Vclose,'Emitter') 
end


% start = sigDACQueryVoltage(DAC,DoorCClosePort);
% deltaParam = 0.05;
% stop = -0.5;
% sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{DoorCClosePort},0);
