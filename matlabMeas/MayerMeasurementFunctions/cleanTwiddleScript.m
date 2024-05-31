
while(SR830Twiddle.SR830queryY() > 4e-5)
    
rampVal(controlDAC,11,-0.5,0.25,0.05,0.05);
delay(10);
rampVal(controlDAC,11,0.25,-0.5,0.05,0.05);
% Check thin film again
rampVal(DoorRight,1,-2,0.45,0.05,0.05);
delay(10);
rampVal(DoorRight,1,0.45,-2,0.05,0.05);
SR830Twiddle.SR830queryY()
end
setVal(DoorRight,2,0.5);