function rampVal(Device,Port,startVal,stopVal,deltaVal,waitTime)
    deltaVal = checkDeltaSign(startVal,stopVal,deltaVal);
    val = startVal:deltaVal:stopVal;

    for v = val
        setVal(Device,Port,v);
        delay(waitTime);
    end
end

