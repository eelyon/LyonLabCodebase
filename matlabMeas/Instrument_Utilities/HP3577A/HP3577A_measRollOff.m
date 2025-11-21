function HP3577A_measRollOff(HP3577A,startFreq,stopFreq,varargin)
%HP3577A_GETROLLOFF Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;
% Line attenuation
p.addParameter('attenuation',76,@isnumeric)
% Settling time
p.addParameter('settling_time',10,@isnumeric)
% Potential divider correction
p.addParameter('pot_divider',1,@isnumeric)
p.parse(varargin{:});

% Set instrument for roll-off measurement
set3577ASweepMode(HP3577A,'SING')
set3577Attenuation(HP3577A,'R','20dB')
set3577Impedance(HP3577A,'R','1Meg')
set3577AStartFrequency(HP3577A,startFreq)
set3577AStopFrequency(HP3577A,stopFreq); delay(1)

sweepTime = get3577ASweepTime(HP3577A);
% stepTime = get3577AStepTime(HP3577A);

set3577ASweepMode(NetworkAnalyzer,'CONT')
set3577Average(NetworkAnalyzer,'128')
% delay(p.Results.settling_time)
delay(128*sweepTime);

[s21_dBm,freqs] = pull3577AData(HP3577A,startFreq,stopFreq); delay(1)
set3577Average(NetworkAnalyzer,'0')
set3577ASweepMode(HP3577A,'SING')

s21_volts = convertdBmToVoltage(s21_dBm+p.Results.attenuatio)*p.Results.pot_divider;
[fit,gof] = fitRollOff(freqs,s21_volts);
fits = fit(freqs);

fig1 = figure();
semilogx(freqs,s21_dBm)
xlabel('Frequency (Hz)','FontSize',15)
ylabel('S_{21} (dBm)','FontSize',15)
saveData(fig1,'RawRollOff');

fig2 = figure();
semilogx(freqs,s21_volts,'b-','DisplayName','Measured S_{21}')
hold on
plot(freqs,fits,'r-','DisplayName',['Cut-off = ',num2str(fit.b,'%.f'),' Hz, A_{v} = ',num2str(max(fits),'%.2f')])
hold off
xlabel('Frequency (Hz)','FontSize',15)
ylabel('Voltage Gain (a.u.)','FontSize',15)
xlim([freqs(1),freqs(end)])
legend('Location','best')
saveData(fig2,'CorrectedRollOff',0);
end

