function [] = setValSIM900( SIM900 , Port, Value )

    fprintf(Device,['CONN ' num2str(Port) ',"xyz"']);
    fprintf(Device,['VOLT ' num2str(Value)]);
    numQueries = 0;
    voltgate = str2double(query(SIM900,'VOLT?'));
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
end