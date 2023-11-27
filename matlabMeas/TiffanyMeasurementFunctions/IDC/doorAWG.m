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
set5122Output(dev1,'OFF');               % turn outputs off 
set5122OutputLoad(dev1,'50');
set5122FunctionType(dev1,'PULSE');
set5122Rise(dev1,6e-9);                  % rise time to 6ns
set5122VoltageHigh(dev1, amp_high);             % sets high level of C1
set5122VoltageLow(dev1,amp_low);                % sets low level of C1

% set Siglent
set5122Period(dev1,TauC*2);
set5122PulseWidth(dev1,TauC);
set5122NumBurstCycles(dev1, 1);          % set num of cycles to burst
set5122BurstStateOn(dev1,'ON');          % enable burst, needs to go here or else will pulse
set5122BurstTriggerSource(dev1,'EXT');
set5122Delay(dev1,delay);
set5122Output(dev1,'ON');                % turn outputs on 

% trigger other agilent to trigger siglent
% set33220Trigger(VpulsAgi,'BUS');  % to open the doors

end
