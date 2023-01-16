function [errorFlag] = setVal( Device, Port ,Value )

  calibrate = 1;
  errorLimit = 1e-3;
  queryLimit = 5;
  
  %% Determine which voltage source is being used
  name = Device.identifier;
  errorFlag = 0;
  if contains(name,'SR830')
    if strcmp(Port,'Freq')
        Device.SR830setFreq(Value);
    elseif strcmp(Port,'Amp')
        Device.SR830setAmplitude(Value);
    else
        Device.SR830setAuxOut(Port,Value);
    end
    
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
    Device.sigDACSetVoltage(Port,Value);
  
  elseif contains(name,'SIM9')
      
      Device.setSIM900Voltage(Port,Value);
      
  elseif contains(name,'33220A')
     if strcmp(Port,'LOW')
        Device.set33220VoltageLow(Value);
    elseif strcmp(Port,'HIGH')
        Device.set33220VoltageHigh(Value);
    elseif strcmp(Port,'WIDT')
        Device.set33220PulseWidth(Value);
    elseif strcmp(Port,'PER')
        Device.set33220PulsePeriod(Value);
    else 
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
  else
    fprintf('\nUnknown Device\n')
    errorFlag = -2;
  end
end

