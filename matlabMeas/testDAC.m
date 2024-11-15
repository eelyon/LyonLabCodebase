ports = 1:1:16;
for i = ports
    setVal(DAC,i,i*0);
    delay(0.05);
end