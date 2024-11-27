%% He film thickness in a channel over density

rho = 145.4;         % [kg/m3] density of liq He
e   = 1.602*10^-19;  % charge of electron
g   = 9.8;           % [m/s2]
sig = 3.34*10^-4;    % [N/m] surface tension at 1.5K
er  = 1.057;         % dielectric constant of He
e0  = 8.85*10^-12;   % in m

w = 7e-6;  % width of channel [m]
t = 660e-9;  % height of channel [m]
h = 6.5e-3;  % distance from bulk He [m]

Rc = @(n) sig/(rho*g*h + (n*1e4)^2*e^2/(2*er*e0));
dmin = @(n) 1e9*(t-Rc(n)*(1-sqrt(1-(w^2/(4*Rc(n)^2)))));
maxDmin = max(dminPlot.YData);

figure(1)
dminPlot = fplot(dmin, [1e8 1e11]);
set(gca(),'XScale','log','YLim',[0 maxDmin*1.1])
title('Helium Channel Filling with Density')
xlabel('Electron Density [#/cm2]');
ylabel('Helium Thickness In Channel [nm]');
