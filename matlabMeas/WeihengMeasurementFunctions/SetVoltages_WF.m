Filament_backing = [15];
Top_metal = [6];
Gates_no_st = [1,2,3,4,5,7,8,9,10,11]; % gates other than sommer tanner l,m,r and top metal and backing
Gates_st = [12,13,14];

% for emission
backing_voltage = -3;
gates_voltage = -1;
st_voltage = 0;
tm_voltage = -1;
sigDACRampVoltage(DAC,Filament_backing,backing_voltage,200);
sigDACRampVoltage(DAC,Top_metal,tm_voltage,200);
for i = 1:length(Gates_no_st)
      sigDACRampVoltage(DAC,Gates_no_st(i),gates_voltage,200);
end
for i = 1:length(Gates_st)
      sigDACRampVoltage(DAC,Gates_st(i),st_voltage,200);
end

% for cleaning
backing_voltage = 3;
negative_bias = -2;
positive_bias = 2;
sigDACRampVoltage(DAC,Top_metal,positive_bias,200);
pause(0.5);
for i = 1:length(Gates_no_st)
      sigDACRampVoltage(DAC,Gates_no_st(i),negative_bias,200);
end
pause(0.5);
for i = 1:length(Gates_st)
      sigDACRampVoltage(DAC,Gates_st(i),negative_bias,200);
end
pause(0.5);
sigDACRampVoltage(DAC,Filament_backing,backing_voltage,200);
pause(0.5);
sigDACRampVoltage(DAC,Top_metal,negative_bias,200);
