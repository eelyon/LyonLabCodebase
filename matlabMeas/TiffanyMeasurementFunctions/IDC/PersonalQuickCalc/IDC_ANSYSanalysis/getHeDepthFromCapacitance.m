function [] = getHeDepthFromCapacitance(delta)
%% Calculates the approximate Helium depth given the difference between 
%% capacitance of the IDC without He and with He referenced to an ANSYS simulation 
%   INPUT: delta = the difference in capacitance in Farads

format long;   % otherwise readtable will cut sig figs
T = readtable('IDC_ANSYSanalysis\CvsHeto1um.csv',"VariableNamingRule","preserve");
HeLevel = T{:,1};
C0 = T{:,2};
C = C0 * 1/(2e-6) * 3.93e-3 * (1/2) * 98; % scaling

find = C(1)+delta;
HeDepth = interp1(C,HeLevel,find);
fprintf(['The Helium depth is ', num2str(HeDepth),'um.\n']);

end