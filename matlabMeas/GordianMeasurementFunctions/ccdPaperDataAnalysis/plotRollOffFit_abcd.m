% [datArr,freqArr] = pull3577AData(HP3577A,startFreq,stopFreq);
path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\';
% path = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\';
day = '02_24_26\';
tag = 'MFLIFreqSweep';
figNum = 24097;

figPath = append(path,day,tag,'_',num2str(figNum),'.fig');
fig = openfig(figPath,"invisible");
data = findobj(fig,'type','line');
freqs = data(3).XData;
s21_volts = data(3).YData;
close(fig);

s21_dB = 20*log10(s21_volts/2e-3);
f = freqs(1):1000:freqs(end);
gain = 22.8;
abcd = fitRollOff_abcd(f,'R',1e6,'Cc',47e-9,'Cin',5.1e-12,'gain',gain);
abcd_dB = 20*log10(abcd);

% file = 'roll_off_circuit_v2_Cin5400fF_R1100kO_20260224';
file = 'roll_off_circuit_v2_data_5100fF_20260224';
opts = detectImportOptions([path,file,'.txt']);
opts.VariableTypes = {'char', 'char'}; % Force everything to text to avoid NaN
T = readtable([path,file,'.txt'], opts);

freq = str2double(T{:, 1}); % Convert "1.00e+00" strings to actual numbers
rawVout = T{:, 2}; % This column looks like: "(-1.12e+01dB,5.69e+01°)"

% Use regexp to find all numbers (including scientific notation and signs)
pattern = '[-+]?\d*\.?\d+([eE][-+]?\d+)?'; % This ignores the "(", "dB", ",", and "°"
extracted = regexp(rawVout, pattern, 'match');

% Every row in 'extracted' should have 2 numbers: [Mag, Phase]
dataMatrix = cellfun(@(x) str2double(x), extracted, 'UniformOutput', false);
dataMatrix = vertcat(dataMatrix{:});
mag_db = dataMatrix(:, 1);
phase_deg = dataMatrix(:, 2);

figure()
semilogx(freqs,10.^(s21_dB/20),'ko','DisplayName','Measured S_{21}')
hold on
% semilogx(f,abcd_dB,'ro','DisplayName','ABCD Fit')
semilogx(freq, 10.^(mag_db/20)*gain,'-','DisplayName','LTSpice')
hold off
xlabel('Frequency (Hz)','FontSize',15)
ylabel('Voltage Gain (arb. units)','FontSize',15)
legend('Location','best')
xlim([freqs(1),freqs(end)])

saveData = table(freqs, y1, y2, 'VariableNames', {'X', 'Line1', 'Line2'});
writetable(saveData, 'plot_data.txt', 'Delimiter', '\t') % Tab-delimited