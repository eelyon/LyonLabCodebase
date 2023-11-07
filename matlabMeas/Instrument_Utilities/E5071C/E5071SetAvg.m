function [] = E5071SetAvg(ENA,AvgOnOff)
%param ENA: Object
%param AvgOnOff: string 'On' or 'Off'

 command = [':SENS1:AVER ',AvgOnOff];
 fprintf(ENA,command);
end