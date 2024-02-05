%% Twiddle/Sense Measurement Procedure (using bias tees)

% with electrons in reservoir go to tranfer configuration
DCConfigDAC(DAC,'Transferring1',8000);
pause(9)

DCConfigDAC(DAC,'Transferring2',8000);
pause(9)

DCConfigDAC(DAC,'TransferTwiddle',8000);
pause(9)

% assuming already have electrons in Emitter, clean them off T&S
Vopen = 0;
Vclose = -0.8;
cleanElectrons(DAC, DoorEInPort,SenseEPort,TwiddleEPort,Vopen,Vclose,'Emitter')
% VtwiddleC.set33220Output(0)
% VdoorModC.set33220Output(0)
twdAmp = 0.3; 
compensateParasitics(VmeasC,VdoorModE,-360,180,10,0.01,twdAmp,0.01,0)

% let electrons in by lowering the door
VdoorOpen = -0.5;
sweep1DMeasSR830({'Door'},Vclose,VdoorOpen,-0.01,0.1,10,{VmeasC},DAC,{DoorEInPort},1,1); 
sweep1DMeasSR830({'Door'},VdoorOpen,Vclose,-0.05,0.3,5,{VmeasC},DAC,{DoorEInPort},1,1); 

% twiddle sense measurement
sweep1DMeasSR830({'TWW'},Vopen,Vopen+0.5,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);

%% Test collector twiddle sense

% 1. transfer lots of electrons
sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort,DoorCClosePort],[0,0,0,0.5],1000); pause(4)
VdoorOpen = -0.4;
sweep1DMeasSR830({'Door'},Vclose,VdoorOpen,-0.01,0.1,10,{VmeasC},DAC,{DoorEInPort},1,1); pause(5)
sweep1DMeasSR830({'Door'},VdoorOpen,Vclose,-0.05,0.3,5,{VmeasC},DAC,{DoorEInPort},1,1); 

% 2. clean electrons off twiddle sense region
cleanElectrons(DAC,DoorCInPort,SenseCPort,TwiddleCPort,0.5,-0.2,'Collector')
sigDACRampVoltage(DAC,SenseCPort,0,1000); pause(1)
compensateParasitics(VmeasE,VdoorModC,-360,180,10,0.01,0.3,0.01,0);

% 3. add electrons
sigDACRampVoltage(DAC,SenseCPort,0.5,1000); pause(1)
sweep1DMeasSR830({'Door'},-0.2,0.5,-0.01,0.1,10,{VmeasC},DAC,{DoorEInPort},1,1); 
sweep1DMeasSR830({'Door'},0.5,-0.2,-0.05,0.3,5,{VmeasC},DAC,{DoorEInPort},1,1); 

% 4. Twiddle Sense measurement
sigDACRampVoltage(DAC,SenseCPort,0,5000); pause(5)
sweep1DMeasSR830({'TWW'},0.5,0.5-0.5,-0.02,0.1,10,{VmeasC},DAC,{TwiddleCPort},1,1);


%% Transfer Pocket

% 1. configuration for transfer
sigDACRampVoltage(DAC,[DoorCInPort,SenseCPort,TwiddleCPort,DoorCClosePort],[-0.2,0,0.5,-0.2],1000); pause(3)
twdAmp = 0.3;
compensateParasitics(VmeasE,VdoorModC,-360,180,10,0.01,twdAmp,0.01,0);
sigDACRampVoltage(DAC,[DoorCClosePort,DoorEInPort,SenseCPort],[0.5,-1,0.5],1000); pause(3)

% 2. transfer pocket of electrons
start = sigDACQueryVoltage(DAC,DoorEClosePort);
deltaParam = -0.025;
stop = -0.4;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);

sigDACRampVoltage(DAC,DoorCClosePort,-0.2,1000); pause(1)

% 3. twiddle measurement
sigDACRampVoltage(DAC,SenseCPort,0,1000); pause(1)
sweep1DMeasSR830({'TWW'},0.5,0.5-0.5,-0.02,0.1,10,{VmeasC},DAC,{TwiddleCPort},1,1);

% 4. clean off electrons into reservoir
cleanElectrons(DAC,DoorCInPort,SenseCPort,TwiddleCPort,0.5,-0.2,'Collector')

% 5. replenish electrons in emitter
VdoorOpen = -0.5;
sweep1DMeasSR830({'Door'},Vclose,VdoorOpen,-0.01,0.1,10,{VmeasC},DAC,{DoorEInPort},1,1); 
sweep1DMeasSR830({'Door'},VdoorOpen,Vclose,-0.05,0.3,5,{VmeasC},DAC,{DoorEInPort},1,1); 










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% twiddle sense measurement
sweep1DMeasSR830({'TWW'},Vopen,Vopen+0.5,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);
% send electrons over
sigDACRampVoltage(DAC,DoorEClosePort,-1,1000);
pause(1)
sigDACRampVoltage(DAC,DoorEInPort,0,1000);
pause(5)
sigDACRampVoltage(DAC,DoorEInPort,-1,1000);
pause(1)
sigDACRampVoltage(DAC,DoorCClosePort,0.8,1000);
pause(1)
sigDACRampVoltage(DAC,DoorEClosePort,0,1000);
pause(5)

sigDACRampVoltage(DAC,DoorCClosePort,-0.1,1000);



% twiddle and sense measurement
twiddleSense1(VmeasC,DAC,TwiddleEPort,VdoorModE,-0.7,0)

% if don't get any electrons
twiddleSensePush(VmeasC,DAC,TwiddleEPort,DoorEInPort,-0.7,0)

%% Transfer
DCConfigDAC(DAC,'Transfer',10000);
pause(11)
sigDACRampVoltage(DAC,[DoorCClosePort,TwiddleCPort,SenseCPort,DoorCInPort,TopCPort],[-0.7,0,0,-0.7,-0.5],1000);
VtwiddleE.set33220Output(0)
VdoorModE.set33220Output(0)

sigDACRampVoltage(DAC,[DoorCClosePort,TwiddleCPort,SenseCPort,DoorCInPort,TopCPort],[0.5,0.5,0.5,-0.3,0],1000);

sigDACRampVoltage(DAC,[DoorCClosePort,TwiddleCPort,SenseCPort,DoorCInPort,TopCPort],[-0.7,0,0,-0.7,-0.5],1000);

sweep1DMeasSR830({'TWW'},0,-0.4,-0.02,0.1,10,{VmeasE},DAC,{TwiddleCPort},1,1);  % measure electrons again


VtwiddleE.set33220Output(1)
VdoorModE.set33220Output(1)

VtwiddleC.set33220Output(0)
VdoorModC.set33220Output(0)

VtwiddleE.set33220Output(0)
VdoorModE.set33220Output(0)


% turn off Emitter
VtwiddleE.set33220Output(0)
VdoorModE.set33220Output(0)
% tune collector side
TuneAmplifier(VmeasE,VtwiddleC,VdoorModC,0.3,89.5e3)
% open collector door
sigDACRampVoltage(DAC,DoorCClosePort,0.5,1000)

% Open and close emitter door
start = -1;
deltaParam = 0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},1,1); 

% close collector door
sigDACRampVoltage(DAC,DoorCClosePort,-0.5,1000)
sweep1DMeasSR830({'TWW'},0.5,0.5+0.4,-0.02,0.1,10,{VmeasE},DAC,{TwiddleCPort},1,1);  % measure electrons again
sweep1DMeasSR830({'TWW'},0,-0.4,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);  % measure electrons again

%% more general transfer (just open doors to ST regions)
sigDACRampVoltage(DAC,DoorEInPort,0,1000);
sigDACRampVoltage(DAC,DoorCInPort,0.5,1000);
sigDACRampVoltage(DAC,DoorCClosePort,0.5,1000)

start = -0.4;
deltaParam = 0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{DoorEClosePort},0);  % open/close door

start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.02;
stop = start-0.2;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.5,5,{VmeasE},DAC,{StmCPort},1);  % ST measurement on collector

%% if works then go back to twiddle/sense measurement

VtwiddleE.set33220Output(0)
VdoorModE.set33220Output(0)
TuneAmplifier(VmeasE,VtwiddleC,VdoorModC,0.2,89.5e3)

function [] = twiddleSense(instr, DAC, twiddleDevice, doorDevice, start, stop)
    % start = -1;
    % stop = 0;

    % bring sense and twiddle to base (-1,0,0,-1)
    sweep1DMeasSR830({'SEN'},start,stop,-0.05,0.5,5,{instr},DAC,{16},0,1);
    sweep1DMeasSR830({'TWW'},start,stop,-0.05,0.5,5,{instr},DAC,{twiddleDevice},0,1);
    
    % TuneAmplifier(instr,twiddleDevice,doorDevice,0.2,100.125e3)

    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},DAC,{doorDevice},0,1); % lower door to let electrons in
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},DAC,{doorDevice},0,1); % raise to close door
    
    % twiddle measurement
%     sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},DAC,{twiddleDevice},1,1);
% 
%     sweep1DMeasSR830({'TWW'},0,-1+0.6,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);
%     sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in
%     sweep1DMeasSR830({'Door'},0,-1,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in
% 
%     sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasE},DAC,{DoorEClosePort},0,1);
% 
%     sweep1DMeasSR830({'Door'},0.5,-0.5,-0.05,0.1,10,{VmeasC},DAC,{DoorCInPort},0,1); % lower door to let electrons in
%     sweep1DMeasSR830({'TWW'},0.5,0.5-0.4,-0.02,0.1,10,{VmeasC},DAC,{TwiddleCPort},1,1);
%     sweep1DMeasSR830({'Door'},-1,-0.1,-0.05,0.1,10,{VmeasE},DAC,{DoorEInPort},0,1); % lower door to let electrons in
% end
% 
% function [] = twiddleSensePush(instr, DAC, twiddleDevice, doorDevice, start, stop)
%     % start = -1;
%     % stop = 0;
%     
%     sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},doorDevice,{5},0,1); % lower door to let electrons in
%     twiddleDevice.set33220VoltageOffset(0.4);
%     sigDACRampVoltage(DAC,STIBiasEPort,-0.4,1000);
%     pause(5)
%     sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},doorDevice,{5},0,1); % raise to close door
%  
%     % twiddle measurement
%     sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},twiddleDevice,{5},1,1);
% end


function [] = cleanElectrons(DAC, DoorInPort, SensePort, TwiddlePort, Vopen, Vclose, type)
    sigDACRampVoltage(DAC,[DoorInPort,SensePort,TwiddlePort],[Vopen,Vopen,Vopen],1000);
    pause(1)
    if strcmp(type,'Emitter')
        sigDACRampVoltage(DAC,TwiddlePort,Vclose,1000);
        pause(5)
        sigDACRampVoltage(DAC,SensePort,Vclose,1000);
        pause(5)
    else
        sigDACRampVoltage(DAC,SensePort,Vclose,1000);
        pause(5)
        sigDACRampVoltage(DAC,TwiddlePort,Vclose,1000);
        pause(5)
    end
    sigDACRampVoltage(DAC,DoorInPort,Vclose,1000);
    pause(1)
    sigDACRampVoltage(DAC,[SensePort,TwiddlePort],[Vopen,Vopen],1000);
    pause(1)
end