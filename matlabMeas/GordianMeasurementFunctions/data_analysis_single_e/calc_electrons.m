function [n_e] = calc_electrons(x,y,cap,gain,alpha)
% Calculate electron number from measured voltage
corr_x = x - x(length(x)); % Subtract background from Re
corr_y = y - y(length(y)); % Subtract background from Imag
corr_mag = sqrt(corr_x.^2 + corr_y.^2); % Calc. magnitude

delta = max(corr_mag) - min(corr_mag); % Calc. change in signal
n_e = (cap*2*sqrt(2)*delta)/(1.602e-19*gain*alpha);
end

