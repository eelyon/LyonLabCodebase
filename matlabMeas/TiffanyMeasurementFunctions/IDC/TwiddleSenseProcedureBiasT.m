%% Twiddle/Sense Measurement Procedure (if use bias tees)

% IDC sweep to make sure there's enough helium
IDCVoltageSweep;

% Emitting configuration
DCConfigDAC(DAC,'Emitting',1000);
sigDACRampVoltage(DAC,DoorEInPort,-1,1000);
sigDACRampVoltage(DAC,TwiddleEPort,0,1000);
sigDACRampVoltage(DAC,SenseEPort,0,1000);
sigDACRampVoltage(DAC,DoorEInPort,-4,1000);
sigDACRampVoltage(DAC,TwiddleEPort,-4,1000);
sigDACRampVoltage(DAC,SenseCPort,-4,1000);
VtwiddleC.set33220Output(0)
VdoorModC.set33220Output(0)

TuneAmplifier(VmeasC,VtwiddleE,VdoorModE,0.2,100.125e3)

% Emit electrons
sigDACRampVoltage(DAC,5,-1.5,10000);
VdoorModE.set33220VoltageOffset(-1);
VtwiddleE.set33220VoltageOffset(-1);
sigDACRampVoltage(DAC,SenseEPort,-1,1000);

start = 0;
deltaParam = 0.05;
stop = -0.5;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);  % ST measurement

% twiddle and sense measurement
twiddleSense(VmeasC,DAC,TwiddleEPort,DoorEInPort,-1,0);  % get 5 plots out of this

% if don't get any electrons
twiddleSensePush(VmeasC,DAC,TwiddleEPort,DoorEInPort,-1,0);  % get 5 plots out of this

%% Transfer
DCConfigDAC(DAC,'Transfer_smaller',10000);
pause(11)
sigDACRampVoltage(DAC,DoorCInPort,-0.5,1000);
sigDACRampVoltage(DAC,TwiddleCPort,0.5,1000);
sigDACRampVoltage(DAC,SenseCPort,0.5,1000);
sweep1DMeasSR830({'TWW'},0,0.4,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);  % measure electrons again
% turn off Emitter
VtwiddleE.set33220Output(0)
VdoorModE.set33220Output(0)
% tune collector side
TuneAmplifier(VmeasE,VtwiddleC,VdoorModC,0.2,89.5e3)
% open collector door
sigDACRampVoltage(DAC,DoorCClosePort,0.5,1000)

% Open and close emitter door
start = -1;
deltaParam = 0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{DoorEClosePort},1,1); 

% close collector door
sigDACRampVoltage(DAC,DoorCClosePort,-0.5,1000)
sweep1DMeasSR830({'TWW'},0.5,0.5+0.4,-0.02,0.1,10,{VmeasE},DAC,{TwiddleCPort},1,1);  % measure electrons again

%% more general transfer (just open doors to ST regions)
sigDACRampVoltage(DAC,DoorEInPort,0,1000);
sigDACRampVoltage(DAC,DoorCInPort,0.5,1000);
sigDACRampVoltage(DAC,DoorCClosePort,0.5,1000)

start = -1;
deltaParam = 0.05;
stop = 0;
sweep1DMeasSR830({'Door'},start,stop,deltaParam,0.05,5,{VmeasC},DAC,{DoorEClosePort},1,1);  % open/close door

start = sigDACQueryVoltage(DAC,20);
deltaParam = -0.02;
stop = start-0.2;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,timeBetweenPoints,repeat,{VmeasC},DAC,{StmCPort},1);  % ST measurement on collector

%% if works then go back to twiddle/sense measurement




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
    sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},DAC,{twiddleDevice},1);
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
    sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},twiddleDevice,{5},1);
end

