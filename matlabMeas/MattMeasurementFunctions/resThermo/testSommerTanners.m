guards = [-0.1, -0.11, -0.12, -0.13, -0.14, -0.15, -0.16, -0.17, -0.18, -0.19, -0.2];

for vg = guards
    sweep1DMeasSR830({'TM'},sigDACQueryVoltage(DAC, 2),vg,0.01,1,30,{SR830},DAC,{2},0);
    sweep1DMeasSR830({'ST'},0,-2,0.25,1,40,{SR830},DAC,{3},1);
end