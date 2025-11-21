% [datArr,freqArr] = pull3577AData(HP3577A,startFreq,stopFreq);
path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\';
day = '11_14_25\';
tag = 'RawRollOff';
figNum = 22421;

figPath = append(path,day,tag,'_',num2str(figNum),'.fig');
fig = openfig(figPath,"invisible");
data = findobj(fig,'type','line');
freqs = data(1).XData;
s21_dBm = data(1).YData;
close(fig);

s21_volts = convertdBmToVoltage(s21_dBm+76)*2;
[fit,gof] = fitRollOff(freqs,s21_volts);
fits = fit(freqs);

s21_dB = 20*log10(s21_volts);

% rolloff = num2str(fit.b);
% s21_fit = a/sqrt((1+x^2/b^2))+c

figure()
semilogx(freqs,s21_dBm)
xlabel('Frequency (Hz)','FontSize',15)
ylabel('S_{21} (dBm)','FontSize',15)

figure()
semilogx(freqs,s21_dB)
xlabel('Frequency (Hz)','FontSize',15)
ylabel('S_{21} (dB)','FontSize',15)

figure()
semilogx(freqs,s21_volts,'b-','DisplayName','Measured S_{21}')
hold on
plot(freqs,fits,'r-','DisplayName',['Cut-off = ',num2str(fit.b,'%.f'),' Hz, A_{v} = ',num2str(max(fits),'%.2f')])
hold off
% % str1 = ['Fitted Rolloff Frequency = ', num2str(fit.b),' Hz'];
% % str2 = ['Max. gain = ', numstr(fit())]
% annotation('textbox',[0.15 0 0.3 0.3],'String',str,'FitBoxToText','on');
xlabel('Frequency (Hz)','FontSize',15)
ylabel('Voltage Gain (a.u.)','FontSize',15)
legend('Location','best')

xlim([freqs(1),freqs(end)])
% % [correctionX,correctionY] = getXYData('Background_S21.fig');
% for i = 1:length(correctionY)
%     correctY(i) = datArr(i)+ 76;
% end
% voltageGain = convertdBmToVoltage(correctY);
% [fit,gof] = fitRollOff(freqArr,voltageGain);
