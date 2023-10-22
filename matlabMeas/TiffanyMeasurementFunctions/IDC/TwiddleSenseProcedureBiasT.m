%% Twiddle/Sense Measurement Procedure (if use bias tees)

% IDC sweep to make sure there's enough helium
IDCVoltageSweep;

% Emitting configuration
DCConfigDAC(DAC,'Emitting',1000);
sigDACRampVoltage(DAC,[DoorEInPort,SenseEPort,TwiddleEPort],[-1,0,0],1000);
VtwiddleC.set33220Output(0)
VdoorModC.set33220Output(0)

TuneAmplifier(VmeasC,VtwiddleE,VdoorModE,0.2,100.125e3)

% Emit electrons
sigDACRampVoltage(DAC,5,-1.5,10000);

start = 0;
deltaParam = 0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

start = 0;
deltaParam = 0.01;
stop = -0.1;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{StmEPort},1);  % ST measurement

% twiddle and sense measurement
twiddleSense(VmeasC,DAC,TwiddleEPort,SenseEPort,DoorEInPort,VtwiddleE,VdoorModE,-0.7,0)

% if don't get any electrons
twiddleSensePush(VmeasC,DAC,TwiddleEPort,DoorEInPort,-0.7,0)

%% Transfer
DCConfigDAC(DAC,'Transfer',10000);
pause(11)
sigDACRampVoltage(DAC,[DoorCClosePort,TwiddleCPort,SenseCPort,DoorCInPort,TopCPort],[-0.7,0,0,-0.7,-0.5],1000);
VtwiddleE.set33220Output(0)
VdoorModE.set33220Output(0)
TuneAmplifier(VmeasE,VtwiddleC,VdoorModC,0.2,89.5e3)

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
    
    TuneAmplifier(instr,twiddleDevice,doorDevice,0.2,100.125e3)

    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},DAC,{doorDevice},0,1); % lower door to let electrons in
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},DAC,{doorDevice},0,1); % raise to close door
    
    % twiddle measurement
    sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},DAC,{twiddleDevice},1,1);

    sweep1DMeasSR830({'TWW'},0,-1+0.6,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);
    sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in
    sweep1DMeasSR830({'Door'},0,-1,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in

    sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasE},DAC,{DoorEClosePort},0,1);

    sweep1DMeasSR830({'Door'},0.5,-0.5,-0.05,0.1,10,{VmeasC},DAC,{DoorCInPort},0,1); % lower door to let electrons in
    sweep1DMeasSR830({'TWW'},0.5,0.5-0.4,-0.02,0.1,10,{VmeasC},DAC,{TwiddleCPort},1,1);
    sweep1DMeasSR830({'Door'},-1,-0.1,-0.05,0.1,10,{VmeasE},DAC,{DoorEInPort},0,1); % lower door to let electrons in
end

function [] = twiddleSensePush(instr, DAC, twiddleDevice, doorDevice, start, stop)
    % start = -1;
    % stop = 0;
    
    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},doorDevice,{5},0,1); % lower door to let electrons in
    twiddleDevice.set33220VoltageOffset(0.4);
    sigDACRampVoltage(DAC,STIBiasEPort,-0.4,1000);
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},doorDevice,{5},0,1); % raise to close door
 
    % twiddle measurement
    sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},twiddleDevice,{5},1,1);
end

