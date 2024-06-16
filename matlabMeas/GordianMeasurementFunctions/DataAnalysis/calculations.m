%% Script for calculating electron density and number of electrons
%% Electron density and filling plot... to do...
% Make plot of d_withElectrons vs electron density for channel width, bulk distance
% Could also just calculate critical electron density for certain filling


%% Bulk LHe calculation for cell
P_atm = 33; % atmospheres of He gas fed into cell
r_cell = 2.7305e-2; % in m
V_panel = (18.44+3.213)*2.54^3/1e6; % gas manifold + T-KF volume from in^3 to m^3
A_cell = pi*(r_cell)^2; % bottom area of cell
cell_depth = 1.6e-3+0.630e-3+10.16e-3; % PCB, device, height from cell bottom to PCB bottom

LHe = P_atm*V_panel/757; % volume of LHe in cell in m^3
h_bulk = cell_depth-LHe/A_cell; % in mm
fprintf(['height from LHe bulk = ', num2str(h_bulk*1e3, '%.1f'), ' mm\n'])

%% Sommer-Tanner
t = 1.25e-6; % channel height
w = 3e-6; % ST channel width
V_pinch = -0.3; % pinch off voltage

Rc = constant().sig/(constant().rho*constant().g*h_bulk); % Rc without electrons
d = t - Rc*(1-sqrt(1-(w^2/(4*Rc^2)))); % assuming no electrons
ne = -(V_pinch*constant().eHe*constant().e0)/(constant().e*d)*1e-4;
fprintf(['electron density from sommer-tanner = ', num2str(ne, '%.3e'), ' cm^-2\n'])

%% Twiddle and Sense
V_rms = 4e-3; % voltage measured by SR830
gain = 40; % gain from HETM amplifier
C_sg = 4e-12; % input capacitance from HEMT
alpha = 1; % fraction of electrons sensed
num_ch = 6; % number of channels measured in parallel

n = ne_twiddle(V_rms,gain,C_sg,alpha,num_ch);
fprintf(['number of electrons from twiddle = ', num2str(n, '%.3e'), ' electrons\n']);

ch_w = 2.5e-6; % channel width
sense_w = 6e-6; % sense gate width
shield_w = 0.5e-6; % shield gate width
tw_w = 2.5e-6; % twiddle gate width

d_twiddle = de_twiddle(n,ch_w,sense_w,shield_w,tw_w);
fprintf(['electron density in twiddle and sense = ', num2str(d_twiddle, '%.3e'), ' cm^-2\n']);

function [d] = d_sommer()
% Calculate electron density from Sommer-Tanner pinch-off data

end

function [n] = ne_twiddle(V_rms,gain,C_sg,alpha,num_ch)
% Calculate number of electrons measured with twiddle and sense
% V_rms: voltage measured by SR830 lock-in
% gain: HEMT amplifier circuit gain
% C_sg: input capacitance of HEMT
% alpha: fraction of electrons actually sense
% num_ch: number of channels across which electrons are measured
    n = V_rms*2*sqrt(2)/gain * C_sg/(1.602e-19*alpha) * 1/num_ch;
end

function [d] = de_twiddle(n_e,ch_w,sense_w,shield_w,tw_w)
% Calculate electron density across twiddle, shield and sense gates
% n_e: number of electrons measured
% ch_w: channel width (in m)
% sense_w: sense gate width (in m)
% shield_w: shield gate width (in m)
% tw_w: twiddle gate width (in m)
% return: electron density per cm^2
    A = ch_w*(sense_w+shield_w+tw_w); % area in m^2
    d = n_e/(A*100^2); % per cm^2
end

function [const] = constant()
    const.m      = 9.10938e-31; % mass of an electron in kg
    const.e      = 1.602e-19;   % charge of an electron in Coulombs
    const.hbar   = 1.054e-34;   % in J*s
    const.h      = 6.626e-32;   % in J*s
    const.hbareV = 6.582e-16;   % in eV*s
    const.heV    = 4.135e-15;   % in eV*s
    const.kb     = 1.3806e-23;  % J/K
    const.kb_eV  = 8.617e-5;    % eV/K
    const.e0     = 8.855e-12;   % F/m
    const.eHe    = 1.057;       % approx. below 2K
    const.g      = 9.80665;     % gravity in m/s^2
    const.sig    = 3.34*10^-4;  % [N/m] surface tension at 1.5K
    const.rho    = 145.4;       % [kg/m3] density of LHe
end