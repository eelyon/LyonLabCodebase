figNums = [14785 14782 14780 14778 14776 14773 14769 14767 14763 14761 14759 14755 14753 14751 14748 14744];
numFigs = length(figNums);

whosePath = 'lab';
tag = 'load';

numEs = [];
yErrs = [];
Vloads = -0.25:0.05:0.5; % [-0.1 0 0.1 0.2 0.3 0.4];

gain = 28.4; % Enter gain from roll-off plot
cap = 5.35*1e-12; % Enter approximate HEMT input capacitance

for n = 1:numFigs
    
    currentFigNum = figNums(n);

    switch whosePath 
        case 'lab'
            path_home = 'C:\Users\Lyon-Lab-B417\Princeton Dropbox\Mayer Feldman\GroupDropbox\Gordian\Experiments\Sandia2023\CCD_Twiddle\08_12_24\';
        case 'gordian'
            path_home = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
        otherwise
            disp('Error! Choose existing path')
    end

    figPath = append(path_home,tag,'_',num2str(currentFigNum),'.fig');

    % Try and catch errors in loop
    try
        fig = openfig(figPath,"invisible");
    catch
        fprintf(['Figure number ', num2str(currentFigNum), ' is missing.\n'])
    end
    
    ax = get(fig,'Children');
    realAxis = findobj(ax(3),'Type','ErrorBar');
    avgReal = realAxis.YData;
    Vshield = realAxis.XData;
    stdReal = realAxis.YPositiveDelta;

    imagAxis = findobj(ax(2),'Type','ErrorBar');
    avgImag = imagAxis.YData;
    stdImag = imagAxis.YPositiveDelta;
    
    mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
    delta = max(mag) - min(mag); % Calc. change in signal
    numE = calcNumElectrons(cap,delta,gain); % Calc. tot. no. of electrons

    stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
    deltaErr = stdm(find(mag==max(mag)))+stdm(find(mag==min(mag)));
    yErr = calcNumElectrons(cap,deltaErr,gain); % Calc. standard deviation for electron no.

    numEs(n) = numE;
    yErrs(n) = yErr;

    close(fig);
end

figure()
fig = errorbar(Vloads,numEs,yErrs,'r.');
xlabel('V_{load} (V)')
ylabel('Total # of Electrons')

function [nE] = calcNumElectrons(cap,Volts,gain)
% Calc. electron number from measured voltage
    nE = (cap*2*sqrt(2)*Volts)/(1.602e-19*gain);
end

function [corrMag] = correctedMag(real,imag)
% Correct measured magnitude by background signal
    corrReal = real - real(length(real)); % Subtract background from Re
    corrImag = imag - imag(length(imag)); % Subtract background from Imag
    corrMag = sqrt(corrReal.^2 + corrImag.^2); % Calc. magnitude
end