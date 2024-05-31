

for i = 1:30
    display(strcat("Loop number ",num2str(i)));
    rampVal(controlDAC,13,-1.8,-3,-0.05,0.05);
    delay(10);
    rampVal(controlDAC,13,-3,-2,-0.05,0.05);
    rampVal(DoorRight,1,1.45,-2,0.05,0.05);
    SR830Twiddle.SR830queryY()
    rampVal(controlDAC,11,-0.5,0,0.05,0.05);
    rampVal(controlDAC,11,0,-0.5,0.05,0.05);
    rampVal(DoorRight,1,-2,1.45,0.05,0.05);
end