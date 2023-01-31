%% Function to bulk set voltages on the DAC

voltSetter = 0;

for i = 1:8
    setVal(DAC,i,voltSetter);
end
