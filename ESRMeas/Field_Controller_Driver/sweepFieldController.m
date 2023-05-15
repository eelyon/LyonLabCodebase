function [] = sweepFieldController(Device, targetField)
  % (1) Module #, (2) conversion factor (Gauss per 1~V), (3) ramp rate(V/s)
  % 1 mV SW gives 0.03 Gauss change in field (min step size for field)
  
  % Max magnet current rate 0.043 A/s => 31 Gauss/s
  % Max SW rate = 0.9 V/s
  %ConnectMag
  CF = struct('module',1,'cal',670.1535,'rate',0.05);
  SW = struct('module',5,'cal',33.604,'rate',0.01);
  
  currentCFVoltage = getVal(Device,CF.module);
  currentCFField = currentCFVoltage*CF.cal;
  
  targetSWVoltage = fix(1000*(targetField-currentCFField)/SW.cal)/1000;
  fprintf(['Sweeping SW Voltage to ' num2str(targetSWVoltage) '\n']);
  rampVal(Device,SW.module,targetSWVoltage,SW.rate,.001);
end

