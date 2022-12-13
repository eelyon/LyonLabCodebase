function [] = connectSIM900Port(instrument,port)
    fprintf(instrument,['CONN ' num2str(port) ',"xyz"']);
end

