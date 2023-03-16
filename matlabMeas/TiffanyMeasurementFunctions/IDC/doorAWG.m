function [ ] = doorAWG(VpulsSig, VpulsAgi,TauE,TauC,delay,unit)
%% generate an pulse sequence using the Agilent to get fast door pulses
%% INPUTS: TauE = emitter door time in whatever unit, TauC = collector door time in whatever unit,
%%         delay = delay in actual time you want it, unit = 'us', 'ms', etc for Agilent
dev1  = VpulsSig;
dev2  = VpulsAgi;
amp_high = 2.5;
amp_low = 0;

if contains(unit,'us')
    TauE = TauE*1e-6;
    TauC = TauC*1e-6;
    delay = delay*1e-6;
elseif contains(unit,'ms')
    TauE = TauE*1e-3;
    TauC = TauC*1e-3;
    delay = delay*1e-3;
elseif contains(unit,'ns')
    TauE = TauE*1e-9;
    TauC = TauC*1e-9;
    delay = delay*1e-9;
elseif contains(unit,'s')
    TauE = TauE;
    TauC = TauC;
    delay = delay;
else
    disp('your unit does not exist!')
end

% set Agilent doorE width
set33220PulsePeriod(dev2,TauE*2)
set33220PulseWidth(dev2, TauE)

% initialize Siglent
set5122Output(Siglent5122,'OFF');               % turn outputs off 
set5122OutputLoad(Siglent5122,'50');
set5122FunctionType(Siglent5122,'PULSE');
set5122Rise(Siglent5122,6e-9);                  % rise time to 6ns
set5122VoltageHigh(dev1, amp_high);             % sets high level of C1
set5122VoltageLow(dev1,amp_low);                % sets low level of C1

% set Siglent
set5122Period(Siglent5122,TauC*2);
set5122PulseWidth(Siglent5122,TauC);
set5122NumBurstCycles(Siglent5122, 1);          % set num of cycles to burst
set5122BurstTriggerSource(Siglent5122,'EXT');
set5122BurstStateOn(Siglent5122,'ON');          % enable burst, needs to go here or else will pulse
set5122Delay(Siglent5122,delay);
set5122Output(Siglent5122,'ON');                % turn outputs on 

% trigger other agilent to trigger siglent
%fprintf(dev2, 'TRIG:SOUR BUS; *TRG');  % to open the doors
end
