format long;   % otherwise readtable will cut sig figs
T = readtable('oldTF.csv',"VariableNamingRule","preserve");
distance = T{:,1};
voltage = T{:,2};
voltageflip = flip(voltage,1)*1e-3;

X = readtable('newTF.csv',"VariableNamingRule","preserve");
distance1 = X{:,1};
voltage1 = X{:,2};


Y = readtable('newerTF.csv',"VariableNamingRule","preserve");
distance2 = Y{:,1};
voltage2 = Y{:,2};
voltageflip2 = flip(voltage2,1);

figure(1)
hold on
plot(distance,voltageflip)
plot(distance1,voltage1)
plot(distance2,voltageflip2)

legend('old','new','newer')
hold off

