% with a glove box
mm = 25.4;     % convert inches to mm
cc = 16.3871;  % convert in3 to cc
in = 0.061;    % convert cc to in

%%  total gas volume of cell
r1 = 1.3/2;  % addition
h1 = 6.36;
r2 = 2.15/2; % top cell
h2 = 0.55;
r3 = 2.15/2; % bottom cell
h3 = 0.3937;
Vgas = (pi*r1^2*h1)+(pi*r2^2*h2)+(pi*r3^2*h3); % in in3
Vgas_cc = Vgas * cc;

% convert to liquid volume
Vliq = Vgas/757;
Vliq_cc = Vliq * cc;
r = r3;
P = 4; % number of bar
h_helium = Vliq*P/(pi*(r)^2)*mm; % comes out in mm

% NOTE The above assumes that is the filling for 1 bar or ~1 atm
% If you add more shots, just multiply the volume by the number of bar