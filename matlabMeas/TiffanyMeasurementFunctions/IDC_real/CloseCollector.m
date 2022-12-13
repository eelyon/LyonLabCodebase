waittime = .1;
Bias = getVal(BiasCDevice,BiasCPort);

for vout = linspace(0,-8,20)

    setVal(DoorCDevice,DoorCPort,vout+Bias);
    pause(waittime)

end