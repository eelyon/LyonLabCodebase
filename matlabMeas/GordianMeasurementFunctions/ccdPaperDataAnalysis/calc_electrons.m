function [n_e] = calc_electrons(corr_mag,cap,gain,alpha)
% Calculate electron number from measured voltage
delta = max(corr_mag) - min(corr_mag); % Calc. change in signal
n_e = (cap*2*sqrt(2)*delta)/(1.602e-19*gain*alpha);
end

