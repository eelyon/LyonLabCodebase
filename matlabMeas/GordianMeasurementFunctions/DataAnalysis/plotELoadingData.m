startNum = 14862;
stopNum  = 14948;
numFigs  = stopNum-startNum;

whosePath = 'lab';
tag = 'load';

numEs = [];
yErrs = [];
Vloads = 1:-0.05:-0.3; % [-0.1 0 0.1 0.2 0.3 0.4];

gain = 26.6; % Enter gain from roll-off plot
cap = 5.05*1e-12; % Enter approximate HEMT input capacitance

switch whosePath 
    case 'lab'
        path_home = 'C:\Users\Lyon-Lab-B417\Princeton Dropbox\Mayer Feldman\GroupDropbox\Gordian\Experiments\Sandia2023\CCD_Twiddle\08_19_24\';
    case 'gordian'
        path_home = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
    otherwise
        disp('Error! Choose existing path')
end

for n = 0:numFigs
    % Try and catch errors in loop
    currentFigNum = startNum + n;
    figPath = append(path_home,tag,'_',num2str(currentFigNum),'.fig');

    if exist(figPath,'file') == 2

        fig = openfig(figPath,"invisible");
        ax = get(fig,'Children');
        realAxis = findobj(ax(3),'Type','ErrorBar');
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
        
        numEs(n+1) = numE;
        yErrs(n+1) = yErr;
        
    else
        fprintf(['Figure number ', num2str(currentFigNum), ' is missing.\n'])
    end

end

figure()
fig = errorbar(Vloads,nonzeros(numEs),nonzeros(yErrs),'r.');
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