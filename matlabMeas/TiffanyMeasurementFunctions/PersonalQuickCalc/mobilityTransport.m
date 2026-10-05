function [ u ] = mobilityTransport( time, Vtf )
%% Calculates the mobility of electrons
% INPUTs: time = time to cross transport line
%         Vtf  =  voltage on transport line  
     
     length = 3.9e-3;
     v     = length/time;  % velocity
     E     = Vtf/length;  % Electric Field
     u     = v/E; 
end