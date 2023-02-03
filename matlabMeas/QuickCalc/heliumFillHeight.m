function [ h ] = heliumFillHeight( Pkpa )
 % calculates the height of He in the cell based on fill volume 
 % INPUTs: Pkpa = pressure of stick after filling with He (read directly
 % from gauge)
 
 littleglassdewar = 1;
 
 if littleglassdewar   
     Vpanel = 18.4;     % in^3
     Vstick = 20.965;   % in^3 
     Acell = pi*0.75^2; % in^2
     Patm = (100+Pkpa)*0.00986923; % atm
     h = Patm * (Vpanel+Vstick)*25.4/(757*Acell); % [mm]

 else  % big glass dewar
     Vpanel = 18.44;     % in^3
     Vstick = 24.24;   % in^3 
     Acell = pi*0.80^2; % in^2
     Patm = (100+Pkpa)*0.00986923; % atm
     h = Patm * (Vpanel+Vstick)*25.4/(757*Acell); % [mm]
 end
end