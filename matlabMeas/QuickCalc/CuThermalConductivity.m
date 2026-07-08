function [ k ] = CuThermalConductivity( T )
% T in kelvin
k = 10^((2.2154-0.88068*T^0.5 + 0.29505*T-0.048310*T^1.5+0.003207*T^2)/(1-0.47461*T^0.5+0.13871*T-0.02043*T^1.5+0.001281*T^2));
end
