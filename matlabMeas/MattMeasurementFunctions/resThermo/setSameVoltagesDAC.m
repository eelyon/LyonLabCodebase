%% Function to bulk set voltages on the DAC

voltSetter = 3.5 - (-0.029);

for i = 1:8
    setVal(DAC,i,voltSetter);
end
