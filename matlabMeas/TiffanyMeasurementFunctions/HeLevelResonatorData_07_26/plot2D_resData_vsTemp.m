figNums = [340:343 347];
peaks = [];

numFigs = length(figNums);

for i=0:numFigs-1
    currentFigNum = figNums(i+1);
%     [currentFigMetaData,figHandle] = displayFigNum(currentFigNum,'visibility',0);
%     closeFigure(figHandle);
%     pause(0.02);  % need this pause for code to work the first time, waits for figures to close
%     
    path_home = 'C:\Users\LyonLab\Documents\GitHub\LyonLabCodebase\matlabMeas\TiffanyMeasurementFunctions\HeLevelResonatorData_07_26\';
    tag = 'HeLevelMeter';
    figPath = append(path_home,tag,'_',num2str(currentFigNum),'.fig');
%     figPathCell = findFigNumPath(currentFigNum);
%     figPath = figPathCell{1};
    [xDat,yDat] = getXYData(figPath,'Type','line','FieldNum',2);
%     [pks,loc] = findpeaks(-yDat,'MinPeakProminence',1);
    [~,min_idx] = min(yDat);
    peaks(i+1) = xDat(min_idx);
end

Temp = [3.95 2.94 1.65 1.28 1.1 ];

figure(1)
plot(Temp,peaks,'.-',LineWidth=1)
xlabel('Temperature (K)')
ylabel('Frequency (GHz)')

