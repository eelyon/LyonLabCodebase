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
    
  elseif strfind(name,',33220A,')
    
     if strcmp(Port,'LOW')
        Value = str2double(query(Device,'VOLT:LOW?')); 
    elseif strcmp(Port,'HIGH')
        Value = str2double(query(Device,'VOLT:HIGH?'));
    elseif strcmp(Port,'WIDT')
        Value = str2double(query(Device,'PULS:WIDT?'));
    elseif strcmp(Port,'PER')
        Value = str2double(query(Device,'PULS:PER?'));
    else 
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
    
    
  else
    fprintf('\nUnknown Device\n')
  end

end

