function [ ] = rampVal( Device, Port, Value, Rate, stepSize)
  if ~exist('stepSize','var')
     stepSize = .001;
  end
  
  startValue = getVal(Device,Port);
  dir = sign(Value-startValue);
  if dir == 0
    error = -3;
  end
  voltOut = startValue:dir*stepSize:Value;
  for Volt = voltOut
    error = setVal(Device,Port,Volt);
    if error < 0
      break
    end
    pause(stepSize/Rate)
  end
  
  if error
    errorDecode(error)
  else
    currentVal = getVal(Device,Port);
    if abs(Value - currentVal) < stepSize
      setVal(Device,Port,Value);
    end
  end
  
end

