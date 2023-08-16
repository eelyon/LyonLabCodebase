%% for quick setup of Filament Agilent parameters

AgilentInUse = Filament;
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