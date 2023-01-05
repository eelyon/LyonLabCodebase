function [ Value ] = getVal( Device, Port)
  %% Determine which voltage source is being used
  name = Device.identifier;
  if strfind(name,'SR830')
    
    Value = Device.SR830queryAuxOut(Port);
  
  elseif strfind(name,'AP24')
    
    Value = Device.sigDACQueryVoltage(Port);
    
  elseif strfind(name,'AP16A')
    
    Value = Device.sigDACQueryVoltage(Port);

  elseif strfind(name,'SIM9')
      
    Value = Device.querySIM900Voltage(Port);
    
  elseif strfind(name,',33220A,')
      
    if Port == 1
        Value = str2double(query(Device,'VOLT:LOW?')); 
    elseif Port == 2
        Value = str2double(query(Device,'VOLT:HIGH?'));
    else 
        fprintf('\nUnknown Port\n')
    end
        
  else
    fprintf('\nUnknown Device\n')
  end

end

