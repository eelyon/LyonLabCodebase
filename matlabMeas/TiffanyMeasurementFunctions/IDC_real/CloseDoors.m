waittime = .1;
Bias = getVal(BiasCDevice,BiasCPort);

for vout = linspace(0,-2,20)

    setVal(DoorCDevice,DoorCPort,vout+Bias);
    pause(waittime)
    
    setVal(DoorEDevice,DoorEPort,vout);
    pause(waittime)

end