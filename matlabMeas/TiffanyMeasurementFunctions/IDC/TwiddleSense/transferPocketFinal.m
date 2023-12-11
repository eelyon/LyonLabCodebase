%% using twiddle sense to send pocket of electrons with transfer back

DCConfigDAC(DAC,'Emitting',1000);
TuneAmplifier(VmeasE,Filament,VdoorModC,0.2,89.5e3)

numPockets = 3;
push = 0; 

% emit electrons
send33220Trigger(Filament);

for i = 1:numPockets
    % close inner door
    sigDACRampVoltage(DAC,DoorEInPort,0,1000); pause(3)
    
    if push
        % if no electrons then add bias
        % sigDACRampVoltage(DAC,STOBiasEPort,-0.3,1000); pause(3)
    end

    sigDACRampVoltage(DAC,DoorEInPort,-1,1000); pause(1)

    % do twiddle, sense to make sure electrons are there
    start = 0;
    deltaParam = -0.05;
    stop = -0.7;
    sweep1DMeasSR830({'TWW'},start,stop,deltaParam,0.1,10,{VmeasE},VtwiddleE,{5},0,1);
    
    % if there are electrons, then open the outer door and transfer
    DCConfigDAC(DAC,'Transferring1',8000); pause(9)
    DCConfigDAC(DAC,'Transferring2',8000); pause(9)
    DCConfigDAC(DAC,'Transfer',8000); pause(9)
    
    sigDACRampVoltage(DAC,DoorEClosePort,0,1000); pause(1)
    sigDACRampVoltage(DAC,DoorCClosePort,1,1000); pause(3)
    sigDACRampVoltage(DAC,DoorEClosePort,-1,1000); pause(1)

    % transfer back leftover electrons keeping the door closed
    DCConfigDAC(DAC,'TransferringBack',8000); pause(9)
    DCConfigDAC(DAC,'TransferBack1',8000); pause(9) 
    DCConfigDAC(DAC,'TransferBack2',8000); pause(9)

    % make sure there are electrons
    start = 1; %sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.02;
    stop = start-0.2;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{StmCPort},1);

    % go back to transfer configuration
    DCConfigDAC(DAC,'Transferring1',8000); pause(9)
    DCConfigDAC(DAC,'Transferring2',8000); pause(9)
    DCConfigDAC(DAC,'Transfer',8000); pause(9)

    % make sure there are electrons
    start = 1; %sigDACQueryVoltage(DAC,StmCPort);
    deltaParam = -0.02;
    stop = start-0.2;
    sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.1,5,{VmeasC},DAC,{StmCPort},1);

end