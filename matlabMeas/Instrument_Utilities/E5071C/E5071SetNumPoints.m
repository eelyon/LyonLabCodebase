function [] = E5071SetNumPoints(ENA,numPoints)
 command = [':SENS1:SWE:POIN ',num2str(numPoints)];
 fprintf(ENA,command);
end