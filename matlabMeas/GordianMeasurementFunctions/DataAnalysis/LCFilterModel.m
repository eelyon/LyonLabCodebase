% Script for modelling LC filter resonance
clear all; close all;

%% Impedance model
% Circuit parameters
Z0 = 50; % Line impedance in Ohms
Cc = 400e-15; % Coupling capacitance in Farads
R = 30; % Effective resistance modelling other circuit losses

% Device
Cidc = 560e-15; % Parasitic capacitance in Farads
% Rd = 100e6; % Device resistance Ohms

% Spiral inductor
L = 15e-9; % Henry
Cl = 100e-15; % Farads
Rl = 0.01; % Inductor resistance due to losses in Ohms

% circuit impedance
Z = @(f) R + ZspiralInductor(L,Cl,Rl,f) + 1/(1i*2*pi*f*Cidc); % + 1/(1i*2*pi*f*Cc) 

numPoints = 1e4;
f = linspace(1e6,3e9,numPoints);

S11spectrum=[];

% calculate S11 for each frequency point
for i = 1:numPoints
    S11spectrum(i) = S11(Z(f(i)),Z0);
end

%% Load data from matlab figure
% path_home = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\Experiments\Sandia2023\Data\HeLevelMeter_LCFilter\12_04_23\';
% path_lab = 'C:\Users\Lyon Lab Simulation\Dropbox (Princeton)\GroupDropbox\Gordian\Experiments\Sandia2023\Data\HeLevelMeter_LCFilter\12_04_23\';
% tag = 'freqHeFilter';
% figNum = 6608;
% figPath = append(path_lab,tag,'_',num2str(figNum),'.fig');
% 
% try
%     fig = openfig(figPath,"reuse","invisible");
% catch
%     fprintf(['Figure number ', num2str(figNum), ' is missing.\n'])
% end
% 
% h = findall(gcf,'Type','line');
% xDat = h(2).XData; % 1 is phase (degrees) data, 2 is magnitude (dB) data
% yDat = h(2).YData;

%% Plot figure
figure();
splot = Magnitude(S11spectrum,-52);
f_GHz = f*1e-9;
plot(f_GHz, splot, '.')
title(['C_c=',num2str(Cc*1e12),'pF, C_{l}=',num2str(Cl*1e15),'fF, C_{idC}=', ...
    num2str(Cidc*1e15),'fF, L=',num2str(L*1e9),'nH, R_l=',num2str(Rl), ...
    '\Omega , R=',num2str(R),'\Omega'])

% hold on; plot(xDat,yDat);

grid on
% xlim([min(f_GHz) max(f_GHz)])
xlabel('Frequency (GHz)'); ylabel('S_{11} (dB)')

%% Functions
function [Z] = ZspiralInductor(L,Cl,Rl,f)
    Z = 1/(1/(1i*2*pi*f*L + Rl) + 1i*2*pi*f*Cl);
end

function [Gamma] = S11(Zc,Z0)
    Gamma = (Zc-Z0)/(Zc+Z0);
end

function [mag] = Magnitude(S11,offsetMag)
    mag = 20*log10(abs(S11)) + offsetMag;
end

function [phase] = Phase(S11,offsetPhase)
    phase = rad2deg(unwrap(atan2(imag(S11),real(S11)))) + offsetPhase;
end
