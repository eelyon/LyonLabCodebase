function [] = amtgas(h)
%% calculates the amount of gas you need to fill the cell for a certain height 
%  INPUTS: h = distance of device from He level in m

Area = pi*(1.075)^2;
H = 12.26e-3-h;                                   % helium level height in cell
amount = H*757*Area/((18.44+3.213)*25.4);      % amount of gas needed in atm
volume = (amount)*(18.44+3.213)*(2.54)^3/757;  % volume of gas in cm^3
% amount = volume/(18.44*(2.54)^3/757)

fprintf(['The He level is ', num2str(H),'mm the amount of gas needed is ', num2str(amount), 'atm the volume is ', num2str(volume), 'cm^3 \n']);

end