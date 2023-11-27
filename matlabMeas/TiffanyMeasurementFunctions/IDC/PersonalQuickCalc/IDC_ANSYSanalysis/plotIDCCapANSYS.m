function [] = plotIDCCapANSYS(filename)
%% Plots the capacitance as a function of He depth taken from ANSYS simulation
%   INPUTS: filename = string file name (ex: 'CvsHeto1um')

format long;   % otherwise readtable will cut sig figs
file = ['IDC_ANSYSanalysis\' filename '.csv'];
T = readtable(file,"VariableNamingRule","preserve");
HeLevel = T{:,1};
C0 = T{:,2};
C = C0 * 1/(2e-6) * 3.93e-3 * (1/2) * 98; % scaling

figure()
set(gcf,'color','w');
plot(HeLevel,C)
xlabel('Helium Depth [um]');
ylabel('Capacitance [pF]'); 
title('IDC: W = 3.3um, G = 3um')
ax=gca; 
ax.YAxis.Exponent = -12;

end