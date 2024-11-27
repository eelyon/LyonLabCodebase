function [density] = electronNumberScope( numSquares , timeScale, voltScale, Igain )
  % calculates roughly the number of electrons you've emitted using the ithaco and oscilloscope
  % divide by area to get roughly the electron density
  e = 1.609*10^-19;
  density = (numSquares*timeScale*voltScale)/(e*Igain);  
end