function [numPoints] = E5071QueryNumPoints(ENA)
  numPoints = str2num(query(ENA,':SENS1:SWE:POIN?\n'));
end

