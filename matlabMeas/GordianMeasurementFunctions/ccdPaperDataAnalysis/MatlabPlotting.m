whosePath = 'B124';
tag = 'Guard1';

% numEs = [];
% yErrs = [];
% Vloads = 1:-0.05:0; % [-0.1 0 0.1 0.2 0.3 0.4];

gain = 24.3*0.915; % Enter gain from roll-off plot
cap = 3.55e-12; % Enter approximate HEMT input capacitance

switch whosePath 
    case 'B417'
        path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\single_electron_sensitivity\data_single_electron_shuttling\10_15_25\';
    case 'B124'
        path = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\11_04_25\';
    case 'gordian'
        path = 'C:\Users\gordi\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\single_electron_sensitivity\data_single_electron_shuttling\09_18_25\';
    otherwise
        disp('Error! Choose existing path')
end

% Try and catch errors in loop
figPath1 = append(path,tag,'_',num2str(21488),'.fig');
% figPath2 = append(path,tag,'_',num2str(20835),'.fig');
% figPath3 = append(path,tag,'_',num2str(20836),'.fig');
% figPath4 = append(path,tag,'_',num2str(20837),'.fig');
% figPath5 = append(path,tag,'_',num2str(20838),'.fig');
% figPath6 = append(path,tag,'_',num2str(20839),'.fig');

figure()
plot_electrons(figPath1,1,2,cap,gain,1)
% plot_electrons(figPath2,1,2,cap,gain,0.2)
% plot_electrons(figPath3,1,2,cap,gain,0.1)
% plot_electrons(figPath4,1,2,cap,gain,0.05)
% plot_electrons(figPath5,1,2,cap,gain,0.01)
% plot_electrons(figPath6,1,2,cap,gain,0.005)

hold off

set(gca,'FontSize',13)
xlabel('V_{guard} (V)','FontSize',14)
ylabel('V_{rms} (\mu V)','FontSize',14)
% xlim([-0.6,0.3])
% ylim([0,0.6])
legend;

% xlim([-1.05,0.25])
% ylim([-0.7,16])

function plot_electrons(figPath,ax1,ax2,cap,gain,Vload)
    fig = openfig(figPath,"invisible");
    ax = get(fig,'Children');
    realAxis = findobj(ax(ax1),'Type','ErrorBar'); %3
    avgReal = realAxis.YData;
    Vshield = realAxis.XData;
    stdReal = realAxis.YPositiveDelta;
    
    imagAxis = findobj(ax(ax2),'Type','ErrorBar'); %4
    avgImag = imagAxis.YData;
    stdImag = imagAxis.YPositiveDelta;
    close(fig);
    
    mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
    delta = max(mag) - min(mag) % mag(3)-mag(end-5); %  Calc. change in signal
    numE = calcNumElectrons(cap,delta,gain) % Calc. tot. no. of electrons
    
    stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
    deltaErr = stdm(find(mag==max(mag)))+stdm(find(mag==min(mag))); % stdm(3)+stdm(end-5); 
    yErr = calcNumElectrons(cap,deltaErr,gain); % Calc. standard deviation for electron no.
    
    display(numE);
    display(yErr);
    errorbar(Vshield,mag*1e6,stdm*1e6,'.-','MarkerSize',14,'DisplayName',['n=',num2str(round(numE),'%d'),' (V_{Dr1,Dr2}=',num2str(Vload),'V)']) % ' (tc=',num2str(Vload),'s)'])
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
    corrReal = real - real(length(real)); % Subtract background from Re
    corrImag = imag  - imag(length(imag)); % Subtract background from Imag
    corrMag = sqrt(corrReal.^2 + corrImag.^2); % Calc. magnitude
end