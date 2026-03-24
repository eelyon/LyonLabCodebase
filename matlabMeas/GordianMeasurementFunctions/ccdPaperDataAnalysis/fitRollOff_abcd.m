function [S21_volts] = fitRollOff_abcd(freq,varargin)
%FitROLLOFF_ABCD Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;
p.addParameter('R',1.1e6,@isnumeric)
p.addParameter('Cc',47e-9,@isnumeric)
p.addParameter('Cin',6.4e-12,@isnumeric)
p.addParameter('gain',20,@isnumeric)
p.parse(varargin{:});

R = p.Results.R;
Cc = p.Results.Cc;
Cin = p.Results.Cin;
gain = p.Results.gain;

Zs = 50;
Zl = 1e12;

% Line resistance from rt to filter: 17 Ohm
% Filter 500 Ohm + 2200 pF & 1200 Ohm + 1000 pF
% Line resistance from filter to PCB: 27 Ohm
% Biasing resistor: ~ 1 MOhm
% Coupling capacitor: 47 nF
% High pass resistor to gnd: ~ 1 MOhm
% Parasitic input capacitance 5-6 pF
% Source load = 50 Ohm
% Input impedance of amplifier: 1 MOhm

% ABCD matrix approach
ABCD = @(freq) [1 17; 0 1]*[1 500; 0 1]*[1 0; 1i*2*pi*freq*2.2e-9 1]*[1 1200; 0 1]...
    *[1 0; 1i*2*pi*freq*1e-9 1]*[1 27; 0 1]*[1 R; 0 1]*[1 1./(1i*2*pi*freq*Cc); 0 1]*[1 0; 1/R 1]*[1 0; 1i*2*pi*freq*Cin 1];
S21 = @(ABCD) Zl/(ABCD(1,1)*Zl + ABCD(1,2) + ABCD(2,1)*Zs*Zl + ABCD(2,2)*Zs);
S21_pts = [];

for i = 1:length(freq)
    S21_pts(i) = S21(ABCD(freq(i)));
end

S21_volts = abs(S21_pts)*gain;
end