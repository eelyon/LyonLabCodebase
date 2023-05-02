function [ d ] = dmin( Rc,w,t )
 % calculates the height of helium in a channel  
 %% INPUTs: Rc = radius of curvature [m]
 %%         w = width of channel [m]           
 %%         t = height of channel [m]
 
    d = t - Rc*(1-sqrt(1-(w^2/(4*Rc^2))));
end