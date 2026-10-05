
figure(2)
format long;   % otherwise readtable will cut sig figs
T = readtable('curveVolt3.csv',"VariableNamingRule","preserve");

length = -T{2:end,2};
scaleLength = length - min(length);
Voltage = T{2:end,4};

plot(scaleLength,Voltage,'.')