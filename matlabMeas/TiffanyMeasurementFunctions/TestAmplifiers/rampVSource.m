function [] = rampVSource(source, chan,startV,stopV,deltaV,deltaTime)
    
    volts = startV:deltaV:stopV;

    for i = volts
        setVolt(source,chan,i);
        delay(deltaTime);
    end
end