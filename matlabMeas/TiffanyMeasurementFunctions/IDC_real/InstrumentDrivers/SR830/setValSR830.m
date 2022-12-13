function [] = setValSR830( SR830, Port, Value )
    fprintf(SR830, ['AUXV' num2str(Port) ',' num2str(Value)]);
end