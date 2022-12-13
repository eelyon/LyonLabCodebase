function [errorFlag] = setVal( Device, Port ,Value )

  calibrate = 1;
  errorLimit = 1e-3;
  queryLimit = 5;
  
  %% Determine which voltage source is being used
  name = query(Device,'*IDN?');
  errorFlag = 0;
  if strfind(name,'SR830')
    
    fprintf(Device, ['AUXV' num2str(Port) ',' num2str(Value)]);
  
  elseif strfind(name,'AP24')
   
    if calibrate
      load(['AP24/AP24_' num2str(Port) '.mat']);
      vRange = -10:.5:10;
      Value = interp1(vRange,vRange.*m+b,Value);
    end
    fprintf(Device,['CH ' num2str(Port)]);
    fprintf(Device,['VOLT ' num2str(Value)]);
    
  elseif strfind(name,'AP16A')
    
    if calibrate
      load(['AP16A/AP16A_' num2str(Port) '.mat']);
      vRange = -10:.5:10;
      Value = interp1(vRange,vRange.*m+b,Value);
    end
    fprintf(Device,['CH ' num2str(Port)]);
    fprintf(Device,['VOLT ' num2str(Value)]);
 
  elseif strfind(name,'SIM9')

      fprintf(Device,['CONN ' num2str(Port) ',"xyz"']);
      fprintf(Device,['VOLT ' num2str(Value)]);
      numQueries = 0;
      voltgate = str2double(query(Device,'VOLT?'));
      while(abs(voltgate - Value) > errorLimit)
        %fprintf([num2str(query(Device,'VOLT?')) '\n'])
        fprintf(['Setting SIM900 port '  num2str(Port)  ' to '  num2str(Value) ' ' ':' ' ' 'Reading' ' ' num2str(voltgate) '\n']);
        fprintf(['Error = ' ' ' num2str(abs(voltgate - Value)) '\n'])
        fprintf(Device,['VOLT ' num2str(Value)]);
        voltgate = str2double(query(Device,'VOLT?'));
        pause(.1)
        numQueries = numQueries + 1;
        if(numQueries == queryLimit)
          errorFlag = -1;
          break
        end
      end
      
      fprintf(Device, 'xyz');
      
  elseif strfind(name,',33220A,')

     if strcmp(Port,'LOW')
        fprintf(Device,['VOLT:LOW' ' ' num2str(Value)]); 
    elseif strcmp(Port,'HIGH')
        fprintf(Device,['VOLT:HIGH' ' ' num2str(Value)]);
    elseif strcmp(Port,'WIDT')
        fprintf(Device,['PULS:WIDT' ' ' num2str(Value)]);
    elseif strcmp(Port,'PER')
        fprintf(Device,['PULS:PER' ' ' num2str(Value)]);
    else 
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
  else
    fprintf('\nUnknown Device\n')
    errorFlag = -2;
  end
end

