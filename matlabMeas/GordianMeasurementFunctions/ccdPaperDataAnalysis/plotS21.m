clear all
whosePath = 'B417';

switch whosePath 
    case 'B417'
        path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\dc_cryo_filter_characterisation\';
    case 'B124'
        path = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\03_06_25\';
    case 'gordian'
        path = 'C:\Users\gordi\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\single_electron_sensitivity\data_single_electron_shuttling\09_18_25\';
    otherwise
        disp('Error! Choose existing path')
end

% Try and catch errors in loop
fileName = '18control_microDtoSMA_att20dB_50OhmInput_controlRTCable_10kHz10MHz';
figPath = append(path,fileName,'.fig');

fig = openfig(figPath,"invisible");
ax = get(fig,'Children');
data = findobj(ax,'Type','Line');
s21_dB = data.YData;
freqs = data.XData;
s21_volts = 10.^(s21_dB/20);
s21_dB_corr = s21_dB-(max(s21_dB));
% close(fig);

% mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
% delta = max(mag) - min(mag); % mag(3)-mag(end-5); %  Calc. change in signal
% numE = calcNumElectrons(cap,delta,gain); % Calc. tot. no. of electrons

% stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
% deltaErr = stdm(find(mag==max(mag)))+stdm(find(mag==min(mag))); % stdm(3)+stdm(end-5); 
% yErr = calcNumElectrons(cap,deltaErr,gain); % Calc. standard deviation for electron no.
% 
% display(numE);
% display(yErr);
figure(1)
fig = semilogx(freqs,s21_dB_corr,'or','MarkerSize',5); %,'DisplayName',['n=',num2str(round(numE),'%d'),' (V_{Dr1,Dr2}=',num2str(Vload),'V)'])

% set(gca,'FontSize',13)
xlabel('Frequency [Hz]','FontSize',14)
ylabel('S_{21} [dB]','FontSize',14)
xlim([freqs(1),freqs(end)])
ylim([min(s21_dB_corr)-1,max(s21_dB_corr)+1])
title([fileName(1:9),' measured from ',num2str(freqs(1)/1e6),' MHz to ',num2str(freqs(end)/1e6),' MHz'])

saveas(fig,[path,fileName,'_plot','.png'])
% legend;