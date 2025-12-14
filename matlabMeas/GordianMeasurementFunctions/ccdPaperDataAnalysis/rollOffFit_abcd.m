function [fitresult,x] = rollOffFit_abcd(freqs,voltageRatio,varargin)
%ROLLOFFFIT_ABCD Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;
p.addParameter('R',1.1e6,@isnumeric)
p.addParameter('Cc',47e-9,@isnumeric)
p.addParameter('Cin',6.4e-12,@isnumeric)
p.addParameter('gain',20,@isnumeric)
p.parse(varargin{:});

R = p.Results.R;
Cc = p.Results.Cc;
x0(1) = p.Results.Cin;
x0(2) = p.Results.gain;
Zs = 50;
Zl = 1e9;

% ABCD matrix approach
% ABCD = @(x,f) [1+(x(1)+1/(1i*2*pi*f*x(2))).*(1/x(1)+1i*2*pi*f*x(3)) x(1)+1/(1i*2*pi*f*x(2)); 1/x(1)+1i*2*pi*f*x(3) 1];
S21_fit = @(x,f) x(2)*abs(Zl./((1+(R+1./(1i*2*pi*f*Cc)).*(1./R+1i*2*pi*f*x(1)))*Zl ...
    + (R+1./(1i*2*pi*f*Cc)) + (1/R+1i*2*pi*f*x(1))*Zs*Zl + 1*Zs));

x0 = [x0(1) x0(2)];
[x,resnorm] = lsqcurvefit(S21_fit,x0,freqs,voltageRatio);

fitresult = [];

for i = 1:length(freqs)
    fitresult = S21_fit(x0,freqs(i));
end
end