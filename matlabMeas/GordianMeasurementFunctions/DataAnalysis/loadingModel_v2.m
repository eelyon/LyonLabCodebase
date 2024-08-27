a = 0.24; % coupling of Sommer-Tanner sense
b = 0.24; % coupling of door 1 and 2
c = 0; % coupling of door 3
d = 0.52; % coupling of top metal

% Let's do everything relative to the top metal
Vst = 0;
Vd12 = 0:1e-2:1;
Vd3 = -0.7;
Vtm = -1; % set top metal positive cause everything is done relative to the top metal

T = 1.8; % K

t_he = 1.17e-6; % depth of lHe in channel

n_st = 1.498e13; % m-^2
area = 1.5*2.5e-6*3e-6; % area of door 1 and 2 (5x3um) in m^2

mu_st = (-constants().e*n_st*t_he)/(constants().eHe*constants().e0) + a*Vst + d*Vtm;
mu_d = a*Vst + b*Vd12 + c*Vd3 + d*Vtm; % at the edge of Sommer-Tanner sense (x=16um)
n_max = (constants().eHe*constants().e0*(a*Vst-d*Vtm))/(constants().e*t_he);
delta = (constants().eHe*constants().e0*(mu_d-mu_st))/(constants().e*t_he)*area;

% E = constants().e*b.*Vd12;
% fermi = (constants().e*b)./(1+exp(-E./(constants().kb*T)));
% boltzmann = exp(-E/(constants().kb*T));
% boltzmann_diff = b*exp(1-E/(constants().kb*T))*1/(constants().kb*T);

figure
plot(Vd12,delta,'DisplayName',['n=',num2str(n_st,'%.3e')])
xlabel("V_{door} (V)")
ylabel("Total # of electrons")
legend