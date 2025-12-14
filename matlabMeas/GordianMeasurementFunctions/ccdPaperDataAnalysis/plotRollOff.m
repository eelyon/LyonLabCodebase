% [datArr,freqArr] = pull3577AData(HP3577A,startFreq,stopFreq);
path = 'C:\Users\Lyon-Lab-B417\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\';
day = '12_09_25\';
tag = 'RawRollOff';
figNum = 22867;

figPath = append(path,day,tag,'_',num2str(figNum),'.fig');
fig = openfig(figPath,"invisible");
data = findobj(fig,'type','line');
freqs = data(1).XData;
s21_dBm = data(1).YData;
close(fig);

s21_volts = convertdBmToVoltage(s21_dBm+76);
% [fit,gof] = fitRollOff(freqs,s21_volts);
% fits = fit(freqs);

% s21_dB = 20*log10(s21_volts);

% [fitresult] = rollOffFit_abcd(freqs,s21_volts,'R',1.1e6,'Cc',47e-9);
% size(fitresult)

R = 1.1e6;
Cc = 47e-9;
x0(1) = 8.2e-12;
x0(2) = 27.2;
Zs = 50;
Zl = 1e12;

% ABCD matrix approach
% ABCD = @(x,f) [1+(x(1)+1/(1i*2*pi*f*x(2))).*(1/x(1)+1i*2*pi*f*x(3)) x(1)+1/(1i*2*pi*f*x(2)); 1/x(1)+1i*2*pi*f*x(3) 1];
% S21_fit = @(x,f) x(2)*abs(Zl./((1+(R+1./(1i*2*pi*f*Cc)).*(1./R+1i*2*pi*f*x(1)))*Zl ...
    % + (R+1./(1i*2*pi*f*Cc)) + (1/R+1i*2*pi*f*x(1))*Zs*Zl + 1*Zs));

% ABCD = @(x,f) [1+(R+1/(1i*2*pi*f*Cc)).*(1/R+1i*2*pi*f*x(1)) R+1/(1i*2*pi*f*Cc); 1/R+1i*2*pi*f*x(1) 1]; % [1 R; 0 1]*[1 1./(2*pi*f*Cc); 0 1].*[1 0; 1/R 1]*[1 0; 2*pi*f*Cin 1];
% S21 = @(ABCD) Zl/(ABCD(1,1)*Zl + ABCD(1,2) + ABCD(2,1)*Zs*Zl + ABCD(2,2)*Zs);
% S21_pts = [];
S21 = @(x,f) x(2)*abs(Zl./((1+(R+1./(1i*2*pi*f*Cc)).*(1./R+1i*2*pi*f*x(1)))*Zl ...
    + (R+1./(1i*2*pi*f*Cc)) + (1/R+1i*2*pi*f*x(1))*Zs*Zl + 1*Zs));

x0 = [x0(1) x0(2)];
[x,resnorm] = lsqcurvefit(S21,x0,freqs,s21_volts);

S21_pts = [];

for i = 1:length(freqs)
    S21_pts(i) = S21(x0,freqs(i));
end

% S21_dB = 20*log10(abs(S21_pts));

% figure()
% semilogx(f,abs(S21_pts)*27)
% % semilogx(f,20*log10(H))
% xlim([f(1),f(end)])

% fitresult = [];
% for i = 1:length(freqs)
%     fitresult = S21(ABCD(x0,freqs(i)))*x0(2);
% end

% rolloff = num2str(fit.b);
% s21_fit = a/sqrt((1+x^2/b^2))+c

figure()
semilogx(freqs,s21_dBm)
xlabel('Frequency (Hz)','FontSize',15)
ylabel('S_{21} (dBm)','FontSize',15)

% figure()
% semilogx(freqs,s21_dB)
% xlabel('Frequency (Hz)','FontSize',15)
% ylabel('S_{21} (dB)','FontSize',15)
% 
figure()
semilogx(freqs,s21_volts,'b-','DisplayName','Measured S_{21}')
hold on
% semilogx(freqs,abs(S21_pts),'r.')%,'DisplayName',['Cut-off = ',num2str(fit.b,'%.f'),' Hz, A_{v} = ',num2str(max(fits),'%.2f')])
plot(freqs,fits,'r-','DisplayName',['Cut-off = ',num2str(fit.b,'%.f'),' Hz, A_{v} = ',num2str(max(fits),'%.2f')])
hold off
% % str1 = ['Fitted Rolloff Frequency = ', num2str(fit.b),' Hz'];
% % str2 = ['Max. gain = ', numstr(fit())]
% annotation('textbox',[0.15 0 0.3 0.3],'String',str,'FitBoxToText','on');
xlabel('Frequency (Hz)','FontSize',15)
ylabel('Voltage Gain (a.u.)','FontSize',15)
legend('Location','best')

% xlim([freqs(1),freqs(end)])
% % [correctionX,correctionY] = getXYData('Background_S21.fig');
% for i = 1:length(correctionY)
%     correctY(i) = datArr(i)+ 76;
% end
% voltageGain = convertdBmToVoltage(correctY);
% [fit,gof] = fitRollOff(freqArr,voltageGain);
