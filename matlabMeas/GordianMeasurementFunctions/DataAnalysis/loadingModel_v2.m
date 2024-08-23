a = 0.01; % coupling of Sommer-Tanner sense
b = 0.47; % coupling of door 1 and 2
c = 0.01; % coupling of door 3
d = 0.51; % coupling of top metal

% Let's do everything relative to the top metal
Vsts = 0;
Vd12 = 0:1e-2:0.4;
Vd3 = -0.7;
Vtm = -1; % set top metal positive cause everything is done relative to the top metal

T = 1.8; % K

t_he = 1.17e-6; % depth of lHe in channel

n_st = 1.498e13; % cm-^2
area = 5e-6*3e-6; % area of door 1 and 2 (5x3um) in m^2
mu_st = (-constants().e*n_st*t_he)/(constants().eHe*constants().e0);

E = constants().e*b.*Vd12;
fermi = (constants().e*b)./(1+exp(-E./(constants().kb*T)));
boltzmann = exp(-E/(constants().kb*T));
boltzmann_diff = b*exp(1-E/(constants().kb*T))*1/(constants().kb*T);
figure
plot(Vd12,boltzmann)