function [ vdW ] = vdWThickness( H )
 % calculates the van der Waals film thickness
 % INPUTs: H = height of device above bulk in cm 
  thin = 1;

  if thin % l<600A
      kv = 2.88*10^-6; % [cm^(4/3)] for metal substrates  
      vdW  = kv*H^(-1/3)*1e7;  % [nm]

  else    % l>600A
      kv = 2.9*10^-6; % [cm^(5/4)]
      vdW = kv*H^(-1/4)*1e7;  % [nm]
  end
end