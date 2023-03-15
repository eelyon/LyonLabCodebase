function [] = initialSet(value, DAC, VmeasE)
DCMap;

if contains(value,'start')
    sigDACSetVoltage(DAC,EPort,0);
    sigDACSetVoltage(DAC,TopMetalPort,-2);
    fprintf(VmeasE, 'AUXV 1,5');
    fprintf(VmeasE, 'AUXV 2,5');
    fprintf(VmeasE, 'AUXV 3,-5');
    fprintf(VmeasE, 'AUXV 4,-5');
else
    fprintf(VmeasE, 'AUXV 1,0');
    fprintf(VmeasE, 'AUXV 2,0');
    fprintf(VmeasE, 'AUXV 3,0');
    fprintf(VmeasE, 'AUXV 4,0');

end
end
