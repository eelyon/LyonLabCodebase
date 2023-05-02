function [ Rc ] = radiusOfCurv( h,opt )
 % calculates the radius of curvature of helium in meters
 %% INPUTs: h = height of device above bulk helium [m]
 %%         n = electron density [1/cm^2] 
  arguments
        h double
        opt {mustBeNonempty} = true
  end

  rho = 145.4;         % [kg/m3] density of liq He
  e   = 1.602*10^-19;  % charge of electron
  g   = 9.8;           % [m/s2]
  sig = 3.34*10^-4;    % [N/m] surface tension at 1.5K
  er  = 1.057;         % dielectric constant of He
  e0  = 8.85*10^-12;   % in m
  
  if opt
    n = opt;
    Rc  = sig/(rho*g*h + (n*1e4)^2*e^2/(2*er*e0)); % [m]  
  else
    Rc  = sig/(rho*g*h); % [m]  
  end 

end