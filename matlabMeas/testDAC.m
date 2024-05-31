ports = 1:1:24;
for i = ports
    setVal(controlDAC,i,i*0);
    delay(0.05);
end