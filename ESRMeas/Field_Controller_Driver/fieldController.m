function [] =  fieldController( Device, targetField )
  % (1) Module #, (2) conversion factor (Gauss per 1~V), (3) ramp rate(V/s)
  % 1 mV CF gives 0.67 Gauss change in field
  % 1 mV SW gives 0.03 Gauss change in field (min step size for field)
  
  % Max magnet current rate 0.043 A/s => 31 Gauss/s
  % Max CF rate = 46 mV/s
  % Max SW rate = 0.9 V/s
  %ConnectMag
  CF = struct('module',1,'cal',670.1535,'rate',0.045);
  SW = struct('module',5,'cal',33.604,'rate',0.1);
  
  %SIM voltage precision is 1mV, get close with CF then correct with SW
  targetCFVoltage = round(1000*(targetField)/CF.cal)/1000;
  fprintf(['Setting Field to ' num2str(targetField) '\n']);
  fprintf(['Setting CF Voltage to ' num2str(targetCFVoltage) '\n']);
  rampVal(Device,CF.module,targetCFVoltage,CF.rate,.005);
  
  targetSWVoltage = fix(1000*(targetField-(targetCFVoltage*CF.cal))/SW.cal)/1000;
  fprintf(['Setting SW Voltage to ' num2str(targetSWVoltage) '\n']);
  rampVal(Device,SW.module,targetSWVoltage,SW.rate,.01);
end

