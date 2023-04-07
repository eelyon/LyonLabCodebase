function [density] = criticalElectronDensity( thickness, varargin )
  % calculates the critical density of electrons
  % INPUTS: thickness = string, if 'thick' will calculate density for thick
  % He film, anything else will do thin film; varargin = optional He film
  % thickness in meters parameter if calculating for thin film
  e = 1.609*10^-19;
  rho = 145; %kg/m^3
  sig = 3.34e-4; %N/m 
  g = 9.8;  %cm/s
  ehe = 1.057;
  e0 = 8.85e-12; % in m 

  if strcmp(thickness,'thick')        % for thick film
    density = 1e-4*((4*rho*g*sig)^(1/4)/(e^2/(ehe*e0))^(1/2));  % per cm^2
  else                                % for thin film
    beta = 3.25e-22; % J, typical for metallic substrate 
    d = varargin{1};
    density = 1e-4*(4*sig*(rho*g+((3*beta)/d^4)))^(1/4)/(e^2/(ehe*e0))^(1/2);  % per cm^2
  end    
  
end