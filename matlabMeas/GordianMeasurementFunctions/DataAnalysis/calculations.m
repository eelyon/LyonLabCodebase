%% Script for calculating electron density and number of electrons
% close all;
% clear all;

%% Device parameters
t = 0.96e-6+250e-9+20e-9; % channel height
w = 3e-6; % ST channel width
V_pinch = -0.6; % pinch off voltage

%% Bulk LHe
T = 1.8; % measurement temperature in K
P_atm = 1; % atmospheres of He gas fed into cell
fprintf(['For ',num2str(P_atm),' atm of He gas:\n'])

r_cell = 2.7305e-2; % in m
V_panel = (18.44+3.213)*2.54^3/1e6; % gas manifold + T-KF volume from in^3 to m^3
A_cell = pi*(r_cell)^2; % bottom area of cell
cell_depth = 1.6e-3+0.630e-3+10.16e-3+0e-3; % PCB, device, height from cell bottom to PCB bottom

LHe = P_atm*V_panel/757; % volume of LHe in cell in m^3
h_bulk = cell_depth-LHe/A_cell; % in m
fprintf(['Height from LHe bulk = ', num2str(h_bulk*1e3, '%.1f'), ' mm\n'])

t_vdW = vdWThick(h_bulk*1e2,"thin"); % output in nm
fprintf(['van der Waals film thickness = ',num2str(t_vdW,'%.1f'),'nm\n'])

%% Sommer-Tanner
fprintf(['Given a channel width of ', num2str(w*1e6),'um:\n'])
sig = surfaceT(T); % surface tension at TK
rc = Rc(sig,h_bulk); % radius of curvature with no electrons
d = ch_depth(rc,w,t); % LHe height in channel
fprintf(['He height in channel = ', num2str(d*1e6),'um\n'])
ne = eD_ST(V_pinch,d);
fprintf(['Electron density from Sommer-Tanner = ', num2str(ne, '%.3e'), ' cm^-2\n'])

%% Plot channel depth vs. electron density
n = linspace(1e8,3e10,1e6); % electron density
rc_withE = Rc(sig,h_bulk,n); % radius of curvature with electrons
d = ch_depth(rc_withE,w,t); % channel depth

figure;
semilogx(n,d*1e6,'b-','DisplayName',['h_{bulk} = ',num2str(h_bulk*1e3,'%.1f'),' mm']);
xlabel('n_{e} (cm^{-2})');
ylabel('channel depth (\mum)');
legend;

%% Twiddle and Sense
V_rms = 4e-3; % voltage measured by SR830
gain = 40; % gain from HETM amplifier
C_sg = 4e-12; % input capacitance from HEMT
alpha = 1; % fraction of electrons sensed
num_ch = 6; % number of channels measured in parallel

n = ne_twiddle(V_rms,gain,C_sg,alpha,num_ch);
% fprintf(['number of electrons from twiddle = ', num2str(n, '%.3e'), ' electrons\n']);

ch_w = 2.5e-6; % channel width
sense_w = 6e-6; % sense gate width
shield_w = 0.5e-6; % shield gate width
tw_w = 2.5e-6; % twiddle gate width

d_twiddle = de_twiddle(n,ch_w,sense_w,shield_w,tw_w);
% fprintf(['electron density in twiddle and sense = ', num2str(d_twiddle, '%.3e'), ' cm^-2\n']);

function [r] = Rc(sig,h,opt)
% Calculates radius of curvature with and without electrons
% sig: surface tension of LHe4 (in N/m)
% h: distance between bulk LHe and top of device (in m)
% opt: if with electrons, enter electron density (in cm^-2)
% return: radius of curvature (in m)
    arguments
        sig double
        h double
        opt {mustBeNonempty} = true
    end

    if opt
        n = opt; % electron density
        r = sig./(constant().rho*constant().g*h + (n*1e4).^2*constant().e.^2./(2*constant().eHe*constant().e0));
    else
        r = sig/(constant().rho*constant().g*h_bulk); % no electrons
    end
end

function [d] = ch_depth(Rc,w,t)
% Calculates LHe depth in channel
% Rc: radius of curvature
% w: channel width (in m)
% t: channel depth (in m)
% return: LHe depth (in m)
    d = t - Rc.*(1-sqrt(1-(w^2./(4*Rc.^2))));
end

function [eD] = eD_ST(V_pinch,d)
% Calculate electron density from Sommer-Tanner pinch-off data
% V_pinch: pinch off voltage measured from Sommer-Tanner (in V)
% d: channel height (in m)
    eD = -(V_pinch*constant().eHe*constant().e0)/(constant().e*d)*1e-4;
end

function [sig] = surfaceT(T)
% Calculate the surface tension of LHe at different temperatures
% From Atkins, The surface tension of liquid helium (1953)
    sig0 = 0.352; % erg/cm^2 at 0K
    sig = (sig0 - 6.9e-3*T^(7/3))*1e-3; % N/m
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

function [t_vdW] = vdWThick(H,l)
 %% calculates the van der Waals film thickness
 % H: height of device above bulk in cm
 % t_ch: channel depth in m
 % return t_vdW: van der Waal's thickness in nm
  if l == "thin" % l < 60e-9
      kv = 2.88*10^-6; % [cm^(4/3)] for metal substrates  
      t_vdW  = kv*H^(-1/3)*1e7;  % [nm]

elseif l == "thick" % l > 60e-9
      kv = 2.9*10^-6; % [cm^(5/4)]
      t_vdW = kv*H^(-1/4)*1e7;  % [nm]
  end
end

function [const] = constant()
    const.m      = 9.10938e-31; % mass of an electron in kg
    const.e      = 1.602e-19;   % charge of an electron in Coulombs
    const.hbar   = 1.054e-34;   % in J*s
    const.h      = 6.626e-32;   % in J*s
    const.hbareV = 6.582e-16;   % in eV*s
    const.heV    = 4.135e-15;   % in eV*s
    const.kb     = 1.3806e-23;  % in J/K
    const.kb_eV  = 8.617e-5;    % in eV/K
    const.e0     = 8.855e-12;   % in F/m
    const.eHe    = 1.057;       % approx. below 2K
    const.g      = 9.80665;     % in m/s^2
    const.sig    = 3.34*10^-4;  % surface tension at 1.5K (in N/m)
    const.rho    = 145.4;       % density of LHe (in kg/m3)
end