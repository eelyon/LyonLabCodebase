mm = 25.4; % convert inches to mm

% total gas volume of cell
r1 = 1.3/2;
h1 = 6.36;
r2 = 2.15/2;
h2 = 0.55;
r3 = 2.15/2;
h3 = 0.3937;
Vgas = (pi*r1^2*h1)+(pi*r2^2*h2)+(pi*r3^2*h3);

% convert to liquid volume
Vliq = Vgas/757;
h_helium = Vliq/(pi*(2.15/2)^2)*mm; % comes out in mm
