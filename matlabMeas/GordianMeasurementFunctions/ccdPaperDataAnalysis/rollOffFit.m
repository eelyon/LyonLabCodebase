R = 1e6;
Cin = 5e-12;
Cc = 47e-9;
Zr = R;
Zline = 50;
f = 10:1:1e6;
Zcc = 1./(2*pi.*f.*Cc);
Zcin = 1./(2*pi.*f.*Cin);

Ztot = Zr + Zcc + 1./(1/Zr+1./Zcin);

S21 = (2*Ztot)./(2+Zline./Ztot);

figure()
loglog(f,S21)
xlim([f(1),f(end)])