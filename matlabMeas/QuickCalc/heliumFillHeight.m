function [ h ] = heliumFillHeight( Pkpa )
 % calculates the height of He in the cell based on fill volume in mm
 %% INPUTs: Pkpa = pressure of stick after filling with He (read directly
 %%                from gauge, if small glass then in kPa, 
 %%                if large glass then in inHg)
 
 littleglassdewar = 0;
 bigglass = 0;
 bigglassRF = 0;
 bigglassGordian = 0;
 bigglassNewRF = 0;
 bombCell = 1;

 if littleglassdewar   
     Vpanel = 18.4;     % in^3
     Vstick = 20.965;   % in^3 
     Acell = pi*0.75^2; % in^2
     Patm = (100+Pkpa)*0.00986923; % converts kpa to atm 
     % little glass dewar gauge has both kpa and inHg 
     h = Patm * (Vpanel+Vstick)*25.4/(757*Acell); % [mm]

 elseif bigglass % big glass dewar (gauge only has inHg)
     Vpanel = 18.44;     % in^3
     Vstick = 24.24;   % in^3 
     Acell = pi*0.80^2; % in^2
     Patm = (30-Pkpa)*0.0334211; % converts inHg to atm
     h = Patm * (Vpanel+Vstick)*25.4/(757*Acell); % [mm]    
 
 elseif  bigglassRF % big glass dewar (RF) 
     Vpanel = 18.44;     % in^3
     Vstick = 24.26;   % in^3 
     Acell = pi*0.75^2; % in^2
     Patm = (30-Pkpa)*0.0334211; % converts inHg to atm
     h = Patm * (Vpanel+Vstick)*25.4/(757*Acell); % [mm]

 elseif  bigglassGordian   % big glass dewar Gordian Cell (RF) 
     Vpanel = 18.44+3.213;     % in^3
     Vstick = 26.19;     % in^3 
     Acell = pi*0.75^2;  % in^2
     Patm = (30-Pkpa)*0.0334211; % atm
     h = Patm * (Vpanel)*25.4/(757*Acell); % [mm]
 
 elseif  bigglassNewRF   % big glass dewar updated RF Cell that Mayer designed (RF) 
     Vpanel = 22.21;       % in^3, Vstick not measured 
     Acell = pi*(0.32/2)^2;      % in^2, 2.15/2
     Patm = (30-Pkpa)*0.0334211; % atm
     h = Patm * (Vpanel)*25.4/(757*Acell); % [mm]
 elseif bombCell
     Vpanel = 5.93;             % in^3
     Acell = pi*(0.32/2)^2;      % in^2, 2.15/2
     Patm = (30-Pkpa)*0.0334211; % atm
     h = Patm * (Vpanel)*25.4/(757*Acell); % [mm]
 elseif bombCell
     Vpanel = 5.93;             % in^3
     Acell = pi*(0.32/2)^2;      % in^2, 2.15/2
     Patm = (30-Pkpa)*0.0334211; % atm
     h = Patm * (Vpanel)*25.4/(757*Acell); % [mm]
 end
end
