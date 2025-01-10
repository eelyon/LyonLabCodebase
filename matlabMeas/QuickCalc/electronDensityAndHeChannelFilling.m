%% solve for electron density (in 1/cm2) and resulting helium film thickness in a channel

Vpinch = -0.2; % pinch off voltage [V]
h = 6.5e-3;    % distance from bulk helium [m]
t = 660e-9;    % height of channel [m]
w = 7.5e-6;    % width of channel [m]

rho = 145.4;         % [kg/m3] density of liq He
e   = 1.602*10^-19;  % charge of electron
g   = 9.8;           % [m/s2]
sig = 3.34*10^-4;    % [N/m] surface tension at 1.5K
er  = 1.057;         % dielectric constant of He
e0  = 8.85*10^-12;   % in m
 

syms f(x)
f(x) = -1 + -1e-4*(Vpinch/x)*er*e0/(e*(t - (sig/(rho*g*h + (x)^2*e^2/(2*er*e0)))*(1-sqrt(1-(w^2/(4*(sig/(rho*g*h + (x)^2*e^2/(2*er*e0)))^2))))));
density = vpasolve(f);

Rc = radiusOfCurv(h, density);
dMin = dmin(Rc,w,t);

Rc_noElect = radiusOfCurv(h);
dMin_noElect = dmin(Rc_noElect,w,t);

fprintf(['The electron density given the pinch off voltage is ', num2str(double(density*1e-9)),'1e9/cm2. \n', 'And the helium depth inside the channel is ', num2str(double(dMin*1e9)),'nm \n']);

fprintf([' The helium depth inside the channel with no electrons is ', num2str(double(dMin_noElect*1e9)),'nm \n']);
