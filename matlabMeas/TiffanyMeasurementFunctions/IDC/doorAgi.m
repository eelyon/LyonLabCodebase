function [ ] = doorAgi(VpulsAgi, VpulsAgi2,TauE,TauC,unit)
%% generates pulses using two Agilents (both have to start at the same time)
% INPUTS: TauE = emitter door time in whatever unit, TauC = collector door time in whatever unit,
%         delay = delay in actual time you want it, unit = 'us', 'ms', etc for Agilent

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

% automatically adjusts Agilent doorE width/period based on what was set before so no error gets thrown
currentPeriodE = str2double(query33220PulsePeriod(dev1));
if currentPeriodE >= TauE*2
    set33220PulseWidth(dev1,TauE)
    set33220PulsePeriod(dev1,TauE*2)
else
    set33220PulsePeriod(dev1,TauE*2)
    set33220PulseWidth(dev1,TauE)
end

% set Agilent doorE width
currentPeriodC = str2double(query33220PulsePeriod(dev2));
if currentPeriodC >= TauC*2
    set33220PulseWidth(dev2,TauC)
    set33220PulsePeriod(dev2,TauC*2)
else
    set33220PulsePeriod(dev2,TauC*2)
    set33220PulseWidth(dev2,TauC)
end

end
