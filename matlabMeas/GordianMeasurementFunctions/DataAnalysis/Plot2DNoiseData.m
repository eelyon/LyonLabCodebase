% Script for getting the FFT from noise data
clear all;

startNum = 6016;
stopNum = 6158;
numFigs = stopNum-startNum;

path_home = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
path_lab = 'C:\Users\Lyon Lab Simulation\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
tag = 'timeDomainSweep';

oldNumShots = 0;
currentNumShots = [];
currentPatm = [];
freqData = [];
cData = [];

for i = 0:2:numFigs
    currentFigNum = startNum + (i);
    figPath = append(path_lab,tag,'_',num2str(currentFigNum),'.fig');
    fig = openfig(figPath,"reuse","invisible");

    currentFigMetaData = fig.UserData;
    currentNumShots(i/2+1) = str2num(currentFigMetaData.numShots);
    currentPatm(i/2+1) = str2num(currentFigMetaData.Patm);

    h = findall(gcf,'Type','line');
    xDat = h(1).XData; % 1 is phase (degrees) data, 2 is magnitude (dB) data
    yDat = h(1).YData;

    [freq,PSD] = PSDfromNoiseData(currentFigMetaData.sTime,currentFigMetaData.numPoints,yDat);

    for k = 1:length(PSD)
        cData(i/2+1,k) = 10*log10(PSD(k));
    end

    close(fig);
    
    if i == 0
        for j = 1:length(freq)
            freqData(j) = freq(j);
        end

    else
        if oldNumShots ~= currentNumShots
        oldNumShots = currentNumShots;
        end
    end
end

LHe_cc = currentPatm.*18.44*2.54^3/757;

figure

%% Interpolate data
pcolor(LHe_cc,freqData,cData.');
shading interp
title("Interpolated Noise Data")

%% Plot uninterpolated data
% image(LHe_cc,freqData,cData.','CDataMapping','scaled')
% set(gca,'YDir','normal')

xlabel('LHe (cm^3)')
ylabel('Frequency (Hz)')
h = colorbar;
h.Label.VerticalAlignment = "bottom";
ylabel(h,'PSD 10log_{10}(\phi/\surd{Hz})','FontSize',10,'Rotation',270)