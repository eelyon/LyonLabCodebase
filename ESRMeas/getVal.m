function [ Value ] = getVal( Device, Port)
  %% Determine which voltage source is being used
  name = query(Device,'*IDN?');
  if strfind(name,'SR830')
    
    Value = str2double(query(Device, ['AUXV?' num2str(Port)]));
  
  elseif strfind(name,'AP24')
    
    fprintf(Device,['CH ' num2str(Port)]);
    Value = str2double(query(Device,'VOLT?'));
    
  elseif strfind(name,'AP16A')
    
    fprintf(Device,['CH ' num2str(Port)]);
    Value = str2double(query(Device,'VOLT?'));
 
  elseif strfind(name,'SIM9')
    fprintf(Device,['CONN ' num2str(Port) ',"xyz"']);
    Value = str2double(query(Device,'VOLT?'));
    fprintf(Device,'xyz');
  else
    fprintf('\nUnknown Device\n')
  end

end

