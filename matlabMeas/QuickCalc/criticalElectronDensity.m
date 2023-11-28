function [density] = criticalElectronDensity( thickness, varargin )
  %% calculates the critical density of electrons per cm^2
  %  INPUTS: thickness = string, 
  %          if 'thick', no other parameter
  %          if 'thin', input He film thickness in meters
  %          if 'fraction', input width of channels in meters

  e   = 1.609*10^-19;
  rho = 145;           % kg/m^3
  sig = 3.34e-4;       % N/m 
  g   = 9.8;           % m/s
  ehe = 1.057;
  e0  = 8.85e-12;      % m 
  cm2 = 1e-4;

  if strcmp(thickness,'thick')        % for thick film
    density = cm2*((4*rho*g*sig)^(1/4)/(e^2/(ehe*e0))^(1/2));  
  
  elseif strcmp(thickness,'thin')     % for thin film
    beta = 3.25e-22; % [J], typical for metallic substrate 
    d = varargin{1};
    density = cm2*(4*sig*(rho*g+((3*beta)/d^4)))^(1/4)/(e^2/(ehe*e0))^(1/2); 
  
  elseif strcmp(thickness,'fraction') % for fractionated He films
    kmin = 1/varargin{1};
    density = cm2*sqrt((sig*kmin)/(e^2/(2*e0*ehe)));    
  end    

end