function [] = initialSet(value, DAC, VmeasE, VpulsAgi)

DCMap;
sigDACSetVoltage(DAC,EPort,0);
sigDACSetVoltage(DAC,TopMetalPort,-2);

if contains(value,'start')
    
    fprintf(VmeasE, 'AUXV 1,5');
    fprintf(VmeasE, 'AUXV 2,5');
    fprintf(VmeasE, 'AUXV 3,-5');
    fprintf(VmeasE, 'AUXV 4,-5');
    
    % initialize Agilent
    amp_high = 2.5;
    amp_low = 0;
    dev1  = VpulsAgi;
    
    set33220FunctionType(dev1,'PULS')
    set33220VoltageHigh(dev1, amp_high*2)
    set33220VoltageLow(dev1, amp_low)
    set33220OutputLoad(dev1, 50)
    
    set33220BurstMode(dev1,'TRIG');
    set33220NumBurstCycles(dev1,1);
    set33220TriggerSource(dev1,'BUS');
    set33220TrigSlope(dev1,'POS');
    set33220BurstStateOn(dev1,'ON');
    set33220Output(dev1,'ON');

else
    fprintf(VmeasE, 'AUXV 1,0');
    fprintf(VmeasE, 'AUXV 2,0');
    fprintf(VmeasE, 'AUXV 3,0');
    fprintf(VmeasE, 'AUXV 4,0');

end
end
