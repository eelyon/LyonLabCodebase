R = 1e6;
Cin = 5e-12;
Cc = 1e-9;
Zr = R;
Zline = 50;
f = 100:10:1e6;
Zcc = 1./(2*pi.*f.*Cc);
Zcin = 1./(2*pi.*f.*Cin);

Ztot = 1./(1./Zcc + 1./Zr);
% Ztot = 1./(1./Zr + 1./(1./Zcc + 1./(1./Zr + 1./Zcin)));
% Ztot = 1./(1./(Zr + Zcc) + 1./1./(1./Zr + 1./Zcin));
% Ztot = Zr + Zcc + 1./(1/Zr + 1./Zcin);

S21 = (2*Ztot)./(2+Zline./Ztot);

figure()
loglog(f,S21)
xlim([f(1),f(end)])