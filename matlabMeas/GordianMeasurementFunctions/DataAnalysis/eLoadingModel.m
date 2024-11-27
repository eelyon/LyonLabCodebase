a = 0.01; % coupling of Sommer-Tanner sense
b = 0.47; % coupling of door 1 and 2
c = 0.01; % coupling of door 3
d = 0.51; % coupling of top metal

% Let's do everything relative to the top metal
Vsts = 0;
Vd12 = 0; % 0:0.01:1;
Vd3 = -0.7;
Vtm = 1; % set top metal positive cause everything is done relative to the top metal

T = 1.8; % K

t_he = 1.17e-6; % depth of lHe in channel

n_st = 1.498e13; % cm-^2
area = 5e-6*3e-6; % area of door 1 and 2 (5x3um) in m^2

mu_sts = (-constants().e*n_st*t_he)/(constants().eHe*constants().e0)+Vsts*b+Vtm*d;
mu_d12 = Vd12.*b+Vtm*d;

N_e = n_st*area;

% numE = (constants().eHe*constants().e0*(a*Vsts+b.*Vd12+d*Vtm+c*Vd3))./(-constants().e*1.23e-6)*area;
delta_mu = mu_d12-mu_sts
ne = (constants().eHe*constants().e.*delta_mu)./(constants().e*t_he)*area

boltzmann = exp((mu_d12-mu_sts)./constants().kb*T);

% figure
% plot(mu,boltzmann);
% figure
% plot(Vd12,ne);