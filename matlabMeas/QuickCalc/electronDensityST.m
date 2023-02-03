function [ n ] = electronDensityST( Vpinch,d )
 % calculates the electron density given pinch off voltage 
 % INPUTs: Vpinch = negative pinch off voltage from STM sweep, 
 % d = ST channel height in m
 e = 1.609*10^-19;
 ehe = 1.057;
 e0 = 8.85e-12; 
 n = -1e-4*Vpinch*ehe*e0/(e*d);  % [num/cm^2]
end