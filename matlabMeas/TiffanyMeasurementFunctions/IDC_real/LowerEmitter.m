waittime = .1;
currentVal = getVal(DoorEDevice,DoorEPort);

for vout = linspace(currentVal,DoorEVoltage,20)
    
    setVal(DoorEDevice,DoorEPort,vout);
    pause(waittime)

end