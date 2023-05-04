function [] = centerFieldController(Device, targetField)
  % (1) Module #, (2) conversion factor (Gauss per 1~V), (3) ramp rate (V/s)
  %ConnectMag
  CF = struct('module',1,'cal',670.1535,'rate',0.1);
  SW = struct('module',5,'cal',33.604,'rate',0.05);
  targetCFVoltage = round(1000*(targetField)/CF.cal)/1000;
  fprintf(['Setting Field to ' num2str(targetField) '\n']);
  fprintf(['Setting CF Voltage to ' num2str(targetCFVoltage) '\n']);
  rampVal(Device,CF.module,targetCFVoltage,CF.rate,.01);
end

