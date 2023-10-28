function [] = E5071SetDataFormat(ENA,dataFormat)

 validDataFormat = {'SLIN','SLOG','SCOM','SMIT','SADM','PLIN','PLOG','POL'};
 if ~any(strcmp(validDataFormat, dataFormat))
   fprintf(['Measurement type: ', dataFormat, ' is not valid.\n']);
   return
 end

 command = [':CALC1:FORM ', dataFormat];
 fprintf(ENA,command);
end