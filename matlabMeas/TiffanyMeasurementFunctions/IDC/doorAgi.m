function [ ] = doorAgi(VpulsAgi, VpulsAgi2,TauE,TauC,unit)
%% generate an pulse sequence using the Agilent to get fast door pulses
%% INPUTS: TauE = emitter door time in whatever unit, TauC = collector door time in whatever unit,
%%         delay = delay in actual time you want it, unit = 'us', 'ms', etc for Agilent
dev1  = VpulsAgi;
dev2  = VpulsAgi2;
amp_high = 2.5;
amp_low = 0;

if contains(unit,'us')
    TauE = TauE*1e-6;
    TauC = TauC*1e-6;
elseif contains(unit,'ms')
    TauE = TauE*1e-3;
    TauC = TauC*1e-3;
elseif contains(unit,'ns')
    TauE = TauE*1e-9;
    TauC = TauC*1e-9;
elseif contains(unit,'s')
    TauE = TauE;
    TauC = TauC;
else
    disp('your unit does not exist!')
end

% set Agilent doorE width
set33220PulsePeriod(dev1,TauE*2)
set33220PulseWidth(dev1, TauE)

% set Agilent doorE width
set33220PulsePeriod(dev2,TauC*2)
set33220PulseWidth(dev2, TauC)

end
