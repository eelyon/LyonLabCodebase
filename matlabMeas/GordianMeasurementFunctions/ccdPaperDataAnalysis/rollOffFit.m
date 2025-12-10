R = 1.1e6;
Cin = 6.4e-12;
Cc = 47e-9;
Zr = R;
Zline = 50;
Zs = 50;
Zl = 1e9;
Z0 = 1e6;
f = 1:2:1e6;
Zcc = 1./(2*pi.*f.*Cc);
Zcin = 1./(2*pi.*f.*Cin);

% Ztot = 1./(1./Zcc + 1./Zr);
% Ztot = 1./(1./Zr + 1./(1./Zcc + 1./(1./Zr + 1./Zcin)));
% Ztot = 1./(1./(Zr + Zcc) + 1./1./(1./Zr + 1./Zcin));
% Ztot = 1./(1./Zcc + 1/Zr); %+ 1./(1/Zr + 1./Zcin);

Z1 = Zr + Zcc;
Z2 = 1./(1/Zr + 1./Zcin);
H = Z2./(Z1 + Z2);

S21 = Zl./(2+Ztot./Zline);

% ABCD matrix approach
ABCD = @(f) [1+(R+1/(1i*2*pi*f*Cc)).*(1/R+1i*2*pi*f*Cin) R+1/(1i*2*pi*f*Cc); 1/Zr+1i*2*pi*f*Cin 1]; % [1 R; 0 1]*[1 1./(2*pi*f*Cc); 0 1].*[1 0; 1/R 1]*[1 0; 2*pi*f*Cin 1];
S21 = @(ABCD) Zl/(ABCD(1,1)*Zl + ABCD(1,2) + ABCD(2,1)*Zs*Zl + ABCD(2,2)*Zs);
S21_pts = [];

for i = 1:length(f)
    S21_pts(i) = S21(ABCD(f(i)));
end

S21_dB = 20*log10(abs(S21_pts));

figure()
semilogx(f,S21_dB)
% semilogx(f,20*log10(H))
xlim([f(1),f(end)])