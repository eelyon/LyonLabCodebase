function [errorFlag] = setVal(Device,Port,Value)

  calibrate = 0;
  errorLimit = 1e-3;
  queryLimit = 5;
  
  %% Determine which voltage source is being used
  name = Device.identifier;
  errorFlag = 0;
  % In reality, we should include a setVal function in each device class.
  % That way it removes any checks and allows us to change functionality in
  % a single place instead of calling specific functions here.
  
  % What if we want to change frequency or amplitude?? This setVal doesn't
  % really let us do that because we default to the aux out. Need to think
  % of a better solution....
  
  if contains(name,'SR830')
    Device.SR830setAuxOut(Port,Value);
  elseif contains(name,'AP24')
    
    if calibrate
      load(['AP24/AP24_' num2str(Port) '.mat']);
      vRange = -10:.5:10;
      Value = interp1(vRange,vRange.*m+b,Value);
    end

    Device.sigDACSetVoltage(Port,Value);

  elseif contains(name,'AP16A')
    
    if calibrate
      load(['AP16A/AP16A_' num2str(Port) '.mat']);
      vRange = -10:.5:10;
      Value = interp1(vRange,vRange.*m+b,Value);
    end
    Device.sigDACSetVoltage(Port,Value)

  elseif contains(name,'SIM9')
      connectSIM900Port(Device,Port);
      setSIM900Voltage(Device,Port,Value);
      disconnectSIM900Port(Device);
  elseif contains(name,',33220A,')
     if Port == 1
        set33220VoltageLow(Device,Value) 
    elseif Port == 2
        set33220VoltageHigh(Device,Value) 
    else 
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
  else
    fprintf('\nUnknown Device\n')
    errorFlag = -2;
  end
end

