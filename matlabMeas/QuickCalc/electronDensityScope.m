function [densityCM] = electronDensityScope( numSquares , timeScale, voltScale, Igain )
  % calculates roughly the density of electrons using the oscilloscope
  e = 1.609*10^-19;
  density = (numSquares*timeScale*voltScale)/(e*Igain);  
  densityCM = density*1e-4;  % per cm
end