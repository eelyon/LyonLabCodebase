% startNum = 20928;
% stopNum  = 20940;
clear all; close all
% numFigs  = [20834,20835,20836,20837,20838,20839]; % time constant
% numFigs  = [20830,20831,20832,20833]; % sampling rate
numFigs  = [20842,20841,20843,20850,20836]; % samples
srats = [837.1,104.6,13.08,13.39e3];

whosePath = 'lab';
tag = 'Guard1';

numEs = [];
yErrs = [];
tc = [];
samples = [];
% Vloads = -0.34:0.02:-0.1; % [-0.1 0 0.1 0.2 0.3 0.4];

gain = 24.3*0.915*100; % Enter gain from roll-off plot
cap = 3.55*1e-12; % Enter approximate HEMT input capacitance

switch whosePath 
    case 'lab'
        path_home = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\single_electron_sensitivity\data_single_electron_shuttling\10_15_25\';
    case 'gordian'
        path_home = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
    otherwise
        disp('Error! Choose existing path')
end

for n = 1:length(numFigs)
    % Try and catch errors in loop
    figPath = append(path_home,tag,'_',num2str(numFigs(n)),'.fig');

    if exist(figPath,'file') == 2

        fig = openfig(figPath,"invisible");
        currentFigMetaData = fig.UserData;
        tc(n) = currentFigMetaData.time_constant;
        samples(n) = currentFigMetaData.length;

        ax = get(fig,'Children');
        currentFigMetaData = fig.UserData;
        realAxis = findobj(ax(1),'Type','ErrorBar');
        avgReal = realAxis.YData;
        Vshield = realAxis.XData;
        stdReal = realAxis.YPositiveDelta;

        imagAxis = findobj(ax(2),'Type','ErrorBar');
        avgImag = imagAxis.YData;
        stdImag = imagAxis.YPositiveDelta;
        close(fig);

        mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
        delta = max(mag) - min(mag); % Calc. change in signal
        numE = calcNumElectrons(cap,delta,gain); % Calc. tot. no. of electrons

        stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
        deltaErr = stdm(find(mag==max(mag)))+stdm(find(mag==min(mag)));
        yErr = calcNumElectrons(cap,deltaErr,gain); % Calc. standard deviation for electron no.
        
        numEs(n) = numE;
        yErrs(n) = yErr;
        
    else
        fprintf(['Figure number ', num2str(currentFigNum), ' is missing.\n'])
    end

end

display(min(yErrs));
display(max(yErrs));
display(mean(yErrs));

display(min(numEs));
display(max(numEs));
display(mean(numEs));

snr = [];
for i = 1:length(numEs)
    snr(i) = numEs(i)/yErrs(i);
end

figure()
fig = plot(samples,snr,'r.','MarkerSize',10);
title([num2str(mean(numEs)),'\pm',num2str(mean(yErrs)),' electrons, tc 0.1 s, 104.6 Sa/s'])
xlabel('samples')
ylabel('SNR')
% xlim([-0.35,-0.11])

function [nE] = calcNumElectrons(cap,Volts,gain)
% Calc. electron number from measured voltage
    nE = (cap*2*sqrt(2)*Volts)/(1.602e-19*gain*0.52);
end

function [corrMag] = correctedMag(real,imag)
% Correct measured magnitude by background signal
    corrReal = real - real(length(real)); % Subtract background from Re
    corrImag = imag - imag(length(imag)); % Subtract background from Imag
    corrMag = sqrt(corrReal.^2 + corrImag.^2); % Calc. magnitude
end