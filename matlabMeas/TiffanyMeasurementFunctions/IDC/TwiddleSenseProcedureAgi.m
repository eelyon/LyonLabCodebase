%% Twiddle/Sense Measurement Procedure (if can leave both on)

% IDC sweep to make sure there's enough helium
IDCVoltageSweep;

% Emitting configuration
DCConfigDAC(DAC,'Emitting',1000);
VdoorModE.set33220VoltageOffset(-1);
VtwiddleE.set33220VoltageOffset(0);
sigDACRampVoltage(DAC,SenseEPort,0,1000);
VdoorModC.set33220VoltageOffset(-4);
VtwiddleC.set33220VoltageOffset(-4);
sigDACRampVoltage(DAC,SenseCPort,-4,1000);

TuneAmplifier(VmeasC,VtwiddleE,VdoorModE,0.2,100.125e3)

% Emit electrons
sigDACRampVoltage(DAC,5,-1.5,10000);
VtwiddleE.set33220VoltageOffset(-1);
sigDACRampVoltage(DAC,SenseEPort,-1,1000);

start = 0;
deltaParam = 0.01;
stop = -0.1;
sweep1DMeasSR830({'ST'},start,stop,deltaParam,0.05,5,{VmeasE},DAC,{19},1);  % ST measurement

%% turn off ST measurement now
% twiddle and sense measurement
twiddleSense(VmeasC,DAC,VtwiddleE,VdoorModE,-1,0);  % get 5 plots out of this

% if don't get any electrons
twiddleSensePush(VmeasC,DAC,VtwiddleE,VdoorModE,-1,0);  % get 5 plots out of this

% Transfer Configuration
DCConfigDAC(DAC,'Transfer_small',1000);



function [] = twiddleSense(instr, DAC, twiddleDevice, doorDevice, start, stop)
    % start = -1;
    % stop = 0;

    % bring sense and twiddle to base (-1,0,0,-1)
    sweep1DMeasSR830({'SEN'},start,stop,-0.05,0.5,5,{instr},DAC,{16},0,1);
    sweep1DMeasSR830({'TWW'},start,stop,-0.05,0.5,5,{instr},twiddleDevice,{5},0,1);
    
    TuneAmplifier(instr,twiddleDevice,doorDevice,0.2,100.125e3)

    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},doorDevice,{5},0,1); % lower door to let electrons in
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},doorDevice,{5},0,1); % raise to close door
    
    % twiddle measurement
    sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},twiddleDevice,{5},1,1);
    
    
    
    %%%%%%%%%%%%%%%%%%%%
    sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasC},VdoorModE,{5},0,1); % lower door to let electrons in
    pause(5)
    sweep1DMeasSR830({'Door'},0,-1,-0.05,0.1,10,{VmeasC},VdoorModE,{5},0,1); % raise to close door
    
    sweep1DMeasSR830({'TWW'},0,-1+0.6,-0.02,0.1,10,{VmeasC},VtwiddleE,{5},1,1);

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

