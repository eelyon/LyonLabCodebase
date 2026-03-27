function [] = E5071AutoScale(ENA)
%param ENA: Object
    command = 'DISP:WIND1:TRAC1:Y:AUTO';
    fprintf(ENA,command);
end