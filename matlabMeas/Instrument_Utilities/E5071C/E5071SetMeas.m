function [] = E5071SetMeas(ENA, traceNum, measType)
% sets the measurement type (S11,S12,S21,S22) for trace number N.
% 
% Arguments:
%
% E5071C: ENA object that contains information about the address and port.
% traceNum: integer representing the trace that will be modified
% measType: string representing the type of measurement to perform. Valid
%           strings are: S11, S12, S21, S22

validMeasType = {'S11','S12','S21', 'S22'};
if ~any(strcmp(validMeasType,measType))
  fprintf(['Measurement type: ', measType, ' is not valid.\n']);
  return
end

cmd = [':CALC', num2str(traceNum), ':PAR', num2str(traceNum), ':DEF ', measType,'\n'];
fprintf(ENA,cmd);

end

