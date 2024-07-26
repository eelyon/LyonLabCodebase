rho = 145.4;         % [kg/m3] density of liq He
e   = 1.602*10^-19;  % charge of electron
g   = 9.8;           % [m/s2]
sig = 3.34*10^-4;    % [N/m] surface tension at 1.5K
er  = 1.057;         % dielectric constant of He
e0  = 8.85*10^-12;   % in m
n = 1e9*1e4;
h = 7e-3;

% d = n^2*e^2/(2*e0*er*rho*g*h);
% d0 = 224e-9; % 32.4359e-9;
% result = d0*(1+d)^(-1/3);
% Rc = radiusOfCurv(7e-3,1e9);
% hi = sig/(rho*g*Rc*h)

n = 1e9;
e   = 1.609*10^-19;
rho = 145;           % kg/m^3
sig = 3.34e-4;       % N/m 
g   = 9.8;           % m/s
ehe = 1.057;
e0  = 8.85e-12;      % m 
cm2 = 1e-4;
h = 2e-3;

depth = 49e-9*(1+n^2*e^2/(2*e0*1.057*rho*g*h))
% w = 12e-6:1e-6:27e-6;
% t = 600e-9;
% Rc = radiusOfCurv(7e-3,1e9);
% size(w)
% dMinList = [];
% 
% for i = w 
%     dMin = dmin(Rc,i,t)
%     dMinList = [dMinList;dMin];
% end
% 
% figure(1)
% plot(w,dMinList)