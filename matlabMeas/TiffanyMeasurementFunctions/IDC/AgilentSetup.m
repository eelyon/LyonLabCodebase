%% for quick setup of the Agilent whether it's being used for the Filament
%% or for twiddle and sense
function [] = AgilentSetup(device, type)

if strcmp(type,'Filament')
    AgilentInUse = device;
    amp_high = 2.4;
    amp_low = 0.5;
    period = 30e-3;
    
    set33220FunctionType(AgilentInUse,'PULS');
    set33220VoltageHigh(AgilentInUse, amp_high);
    set33220VoltageLow(AgilentInUse, amp_low);
    set33220PulsePeriod(AgilentInUse,period);
    set33220PulseDutyCycle(AgilentInUse,90);
    set33220PulseRiseTime(AgilentInUse,5e-9);
    
    set33220OutputLoad(AgilentInUse,'INF');
    set33220BurstMode(AgilentInUse,'TRIG');
    set33220NumBurstCycles(AgilentInUse,1);
    set33220TriggerSource(AgilentInUse,'BUS');
    set33220TrigSlope(AgilentInUse,'POS');
    set33220BurstStateOn(AgilentInUse,'ON');
    set33220Output(AgilentInUse,'ON');

else 
    % initialize Agilent
    amplitude = 500e-3;
    voltType = 'VRMS';
    voltageOffset = 0;
    frequency = 89.5e3;
    
    devices  = device;
    
    for i = 1:length(devices)
            set33220FunctionType(devices(i),'SIN');
            set33220VoltageOffset(devices(i),voltageOffset)
            set33220Frequency(devices(i),frequency);
            if i == 1
                set33220Phase(devices(i),0);
                set33220Amplitude(devices(i),amplitude,voltType);
            else
                set33220Phase(devices(i),6.18);
                set33220Amplitude(devices(i),0.076,voltType);
            end
            set33220OutputLoad(devices(i), 'INF');
            set33220Output(devices(i),0);  % start with output OFF
            set33220BurstStateOn(devices(i),0)  % turn burst state off
    end 
end

end