whosePath = 'B124';
tag = 'Guard1';

% numEs = [];
% yErrs = [];
% Vloads = 1:-0.05:0; % [-0.1 0 0.1 0.2 0.3 0.4];

gain = 24.2*0.889; % Enter gain from roll-off plot
cap = 3.31e-12; % Enter approximate HEMT input capacitance

switch whosePath 
    case 'B417'
        path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\11_03_25\';
    case 'B124'
        path = 'C:\Users\Lyon-Lab-B417\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\';
    case 'gordian'
        path = 'C:\Users\gordi\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\single_electron_sensitivity\data_single_electron_shuttling\09_18_25\';
    otherwise
        disp('Error! Choose existing path')
end

% Try and catch errors in loop
figPath1 = append([path, '11_05_25\'],tag,'_',num2str(21778),'.fig');
figPath2 = append([path, '11_05_25\'],tag,'_',num2str(21776),'.fig');
figPath3 = append([path, '11_05_25\'],tag,'_',num2str(21774),'.fig');
figPath4 = append([path, '11_05_25\'],tag,'_',num2str(21772),'.fig');
figPath5 = append([path, '11_05_25\'],tag,'_',num2str(21770),'.fig');
figPath6 = append([path, '11_05_25\'],tag,'_',num2str(21768),'.fig');
% figPath7 = append([path, '11_06_25\'],tag,'_',num2str(21803),'.fig');
% figPath8 = append(path,tag,'_',num2str(21425),'.fig');

figure()
p1 = plot_electrons(figPath1,1,2,cap,gain);
p2 = plot_electrons(figPath2,1,2,cap,gain);
p3 = plot_electrons(figPath3,1,2,cap,gain);
p4 = plot_electrons(figPath4,1,2,cap,gain);
p5 = plot_electrons(figPath5,1,2,cap,gain);
p6 = plot_electrons(figPath6,1,2,cap,gain);
% plot_electrons(figPath7,1,2,cap,gain)
% plot_electrons(figPath8,1,2,cap,gain)

xline(-0.38,'b--','LineWidth',2)
xline(-0.44,'b--','LineWidth',2)
xline(-0.64,'k--','LineWidth',2)
xline(-0.7,'k--','LineWidth',2)

hold off

set(gca,'FontSize',13)
title(['gain = ',num2str(round(gain,1)), ', C_{in} = ',num2str(cap)],'FontSize',12)
xlabel('V_{guard} (V)','FontSize',14)
ylabel('V_{rms} (\mu V)','FontSize',14)
xlim([-0.71,0.31])
% ylim([0,0.6])
legend([p1,p2,p3,p4,p5,p6]);

% xlim([-1.05,0.25])
% ylim([-0.7,16])

function [plotHandle] = plot_electrons(figPath,ax1,ax2,cap,gain)
    fig = openfig(figPath,"invisible");
    ax = get(fig,'Children');
    realAxis = findobj(ax(2),'Type','ErrorBar'); %3
    real = realAxis.YData;
    xvals = realAxis.XData;
%     stdReal = realAxis.YPositiveDelta;
    
    imagAxis = findobj(ax(1),'Type','ErrorBar'); %4
    imag = imagAxis.YData;
%     stdImag = imagAxis.YPositiveDelta;
    close(fig);
    
    mag = correctedMag(real,imag); % Get corrected magnitude
    edge = round((0.3--0.62)/0.01+1);
    avgOff = mean(mag(edge:end));
    stdOff = std(mag(edge:end));
    
    edge1 = round((0.3--0.38)/0.01+1);
    edge2 = round((0.3--0.44)/0.01+1);
    avgOn = mean(mag(edge1:edge2));
    stdOn = std(mag(edge1:edge2));

%     delta = max(mag) - min(mag); % mag(3)-mag(end-5); %  Calc. change in signal
    delta = avgOn - avgOff;
    numE = calcNumElectrons(cap,delta,gain); % Calc. tot. no. of electrons
    
%     stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
%     deltaErr = stdm(find(mag==max(mag)))+stdm(find(mag==min(mag))); % stdm(3)+stdm(end-5);
    deltaErr = stdOff + stdOn;
    yErr = calcNumElectrons(cap,deltaErr,gain); % Calc. standard deviation for electron no.
    
%     display(numE);
%     display(yErr);
    plotHandle = plot(xvals,mag*1e6,'.-','MarkerSize',14,'DisplayName',['n_{e}= ',num2str(numE,'%.2f'),'\pm',num2str(yErr,'%.2f')]);
%     errorbar(xvals,mag*1e6,stdm*1e6,'.-','MarkerSize',14,'DisplayName',['n=',num2str(round(numE,1)),' (V_{d1,d2} = ',num2str(Vload),' V)']) % ' (tc=',num2str(Vload),'s)'])
%     ['n = ',num2str(numE,'%.1f'),' ',177, ' ', num2str(yErr,'%.1f')]
%     legend('n = %i', numE);
    hold on
end

function [nE] = calcNumElectrons(cap,Volts,gain)
% Calc. electron number from measured voltage
    nE = (cap*2*sqrt(2)*Volts)/(1.602e-19*gain*0.52);
end

function [corrMag] = correctedMag(real,imag)
% Correct measured magnitude by background signal
    edge = round((0.3--0.64)/0.01+1);
    corrReal = real - mean(real(edge:end)); % real(length(real)); % Subtract background from Re
    corrImag = imag  - mean(imag(edge:end)); % imag(length(imag)); % Subtract background from Imag
    corrMag = sqrt(corrReal.^2 + corrImag.^2); % Calc. magnitude
end