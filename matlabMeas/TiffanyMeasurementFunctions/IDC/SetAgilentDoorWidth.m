function [ ] = SetAgilentDoorWidth(device1,device2,Tau1,Tau2)
%% generates pulses using two Agilents (both pulses have to start at the same time)
% INPUTS: Tau1 = emitter door time in whatever unit, Tau2 = collector door time in whatever unit
% automatically adjusts Agilent doorE width/period based on what was set before so no error gets thrown


currentPeriodE = str2double(query33220PulsePeriod(device1));
if currentPeriodE >= Tau1*2
    set33220PulseWidth(device1,Tau1)
    set33220PulsePeriod(device1,Tau1*2)
else
    set33220PulsePeriod(device1,Tau1*2)
    set33220PulseWidth(device1,Tau1)
end

% set Agilent doorC width
currentPeriodC = str2double(query33220PulsePeriod(device2));
if currentPeriodC >= Tau2*2
    set33220PulseWidth(device2,Tau2)
    set33220PulsePeriod(device2,Tau2*2)
else
    set33220PulsePeriod(device2,Tau2*2)
    set33220PulseWidth(device2,Tau2)
end

end
