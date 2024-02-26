function [ ] = doorSiglent(VpulsSig,TauE,TauC,delay,unit)
%% generates a pulse sequence using an Agilent and a Siglent (pulses don't have to start together)
% INPUTS: TauE = emitter door time in whatever unit, TauC = collector door time in whatever unit,
%         delay = delay in actual time you want it, unit = 'us', 'ms', etc for Agilent
initialize = 0;
dev  = VpulsSig;
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

if initialize
    % initialize Siglent
    for i = 1:2
        set5122Output(dev,0,i);                     % turn outputs off 
        set5122OutputLoad(dev,'50',i);
        set5122FunctionType(dev,'PULSE',i);
        set5122Rise(dev,6e-9,i)                     % rise time to 6ns
        set5122VoltageHigh(dev,amp_high,i)          % sets high level
        set5122VoltageLow(dev,amp_low,i);           % sets low level
    end 
else
end

% set Siglent
set5122Period(dev,TauE*2,1);
set5122PulseWidth(dev,TauE,1);
set5122Period(dev,TauC*2,2);
set5122PulseWidth(dev,TauC,2);

% set5122NumBurstCycles(dev,1,1);          % set num of cycles to burst
% set5122NumBurstCycles(dev,1,2);          % set num of cycles to burst
% 
% set5122BurstStateOn(dev,1,1);          % enable burst, needs to go here or else will pulse
% set5122BurstStateOn(dev,1,2);          % enable burst, needs to go here or else will pulse
% 
% set5122BurstTriggerSource(dev,'MAN',1);
% 
% set5122BurstTriggerSource(dev,'EXT',2);
% 
% set5122Delay(dev,delay,2);
% set5122Output(dev,1,1);                % turn outputs on 
% set5122Output(dev,1,2);                % turn outputs on 

end
