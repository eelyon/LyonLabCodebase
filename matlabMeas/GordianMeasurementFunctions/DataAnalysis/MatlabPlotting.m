whosePath = 'B417';
tag = 'Guard1';

% numEs = [];
% yErrs = [];
% Vloads = 1:-0.05:0; % [-0.1 0 0.1 0.2 0.3 0.4];

gain = 23.8*0.9; % Enter gain from roll-off plot
cap = 3.3*1e-12; % Enter approximate HEMT input capacitance

switch whosePath 
    case 'B417'
        path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensitivity\Data_SingleElectronShuttling\09_18_25\';
    case 'B124'
        path = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\03_06_25\';
    case 'gordian'
        path = 'C:\Users\gordi\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Presentations\PQI Retreat Feb2025\Images\';
    otherwise
        disp('Error! Choose existing path')
end

% Try and catch errors in loop
currentFigNum = 20483;
figPath = append(path,tag,'_',num2str(currentFigNum),'.fig');

fig = openfig(figPath,"invisible");
ax = get(fig,'Children');
realAxis = findobj(ax(2),'Type','ErrorBar');
avgReal = realAxis.YData;
Vshield = realAxis.XData;
stdReal = realAxis.YPositiveDelta;

imagAxis = findobj(ax(1),'Type','ErrorBar');
avgImag = imagAxis.YData;
stdImag = imagAxis.YPositiveDelta;
close(fig);

mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
delta = mag(3)-mag(end-5); % max(mag) - min(mag); % Calc. change in signal
numE = calcNumElectrons(cap,delta,gain); % Calc. tot. no. of electrons

stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
deltaErr = stdm(3)+stdm(end-5); % stdm(find(mag==max(mag)))+stdm(find(mag==min(mag)));
yErr = calcNumElectrons(cap,deltaErr,gain); % Calc. standard deviation for electron no.

display(numE);
display(yErr);
figure()
errorbar(Vshield,mag*1e6,stdm*1e6,'r.','MarkerSize',10)
set(gca,'FontSize',13)
xlabel('V_{guard} (V)','FontSize',14)
ylabel('V_{rms} (\mu V)','FontSize',14)
% xlim([-1.05,0.25])
% ylim([-0.7,16])

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