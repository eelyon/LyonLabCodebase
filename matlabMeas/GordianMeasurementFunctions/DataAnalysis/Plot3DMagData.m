% Script for plotting the resonator data obtained in the He level meter
% experiment.
% date: 15th Oct. 2023
% clear all;

consecutive = 1;
if consecutive
    startNum = 11982;
    stopNum  = 12035;
    numFigs  = stopNum-startNum;
else
    figNums = [10775 10777 10779 10780 10783:10787 10790];
    numFigs = length(figNums);
end

whosePath = 'lab';
tag = 'freqSweep';

oldNumShots = 0;
currentNumShots = [];
currentPatm = [];
tempData = [];
freqData = [];
cData = [];

for i = 0:2:numFigs
    
    if consecutive
        currentFigNum = startNum + (i);
    else
        currentFigNum = figNums(i/2+1);
    end

    switch whosePath 
        case 'lab'
            path_home = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\04_12_24\';
        case 'gordian'
            path_home = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
        case 'tiffany'
            if currentFigNum <= 7312 %7037
                path_home = 'C:\Users\LyonLab\Dropbox (Princeton)\GroupDropbox\Tiffany\Application\MATLAB\Data\12_07_23\';
            else
                path_home = 'C:\Users\LyonLab\Dropbox (Princeton)\GroupDropbox\Tiffany\Application\MATLAB\Data\12_08_23\';
            end
        otherwise
            disp('Error! Choose existing path')
    end

    figPath = append(path_home,tag,'_',num2str(currentFigNum),'.fig');

    % Try and catch errors in loop
    try
        fig = openfig(figPath,"reuse","invisible");
    catch
        fprintf(['Figure number ', num2str(currentFigNum), ' is missing.\n'])
    end

    currentFigMetaData = fig.UserData;

    try
        currentNumShots(i/2+1) = str2num(currentFigMetaData.numShots);
    catch
        fprintf('numShots not found in metaData.\n');
    end

    try
        currentPatm(i/2+1) = str2num(currentFigMetaData.Patm);
    catch
        fprintf('Patm not found in metaData.\n')
    end

%     try
%         tempData(i/2+1) = str2num(currentFigMetaData.temperature);
%     catch
%         fprintf('TempData not found.\n')
%     end

    h = findall(gcf,'Type','line');
    xDat = h(2).XData; % 1 is phase (degrees) data, 2 is magnitude (dB) data
    yDat = h(2).YData;
    xDat = xDat;
    yDat = yDat;

    for k = 1:length(yDat)
        cData(i/2+1,k) = yDat(k);
    end

    close(fig);
    
    if i == 0
        for j = 1:length(xDat)
            freqData(j) = xDat(j);
        end

%     else
%         if oldNumShots ~= currentNumShots
%         oldNumShots = currentNumShots;
%         end
    end
end

LHe_cc = currentPatm.*(18.44+3.213)*2.54^3/757;

figure

%% Interpolate data
% pcolor(LHe_cc,freqData,cData.');
% shading interp
% title("Interpolated Noise Data")

%% Plot uninterpolated data
image(LHe_cc,freqData,cData.','CDataMapping','scaled')
set(gca,'YDir','normal')

xlabel('LHe (cm^3)')
% xlabel('Temperature (K)')
ylabel('Frequency (GHz)')
% ylim([1.330,1.355])
h = colorbar;
h.Label.VerticalAlignment = "bottom";
ylabel(h,'S_{21} (dB)','FontSize',10,'Rotation',270)