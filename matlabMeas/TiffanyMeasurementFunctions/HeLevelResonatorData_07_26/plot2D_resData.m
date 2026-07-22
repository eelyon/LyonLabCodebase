figNums = [347 349 350 352 374 381 396 406 409:431];
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

atm_added = [0 1 2 2.65];
h_small = 1.745*atm_added;
volume = pi*(4.064)^2*h_small; % in mm
smallLHe_cc = volume*0.001; % mm3 to cc

atm_added_2 = [3.65 4.65 5.65];
h_large = 0.0387*atm_added_2;
volume2 = pi*(27.305)^2*h_large; % in mm
largeLHe_cc = volume2*0.001;

atm_added_3 = [1 4:14 14.35 14.89 15.35:0.5:19.35 20.35];
h_largest = 0.1973*atm_added_3;
volume3 = pi*(27.305)^2*h_largest; % in mm
largestLHe_cc = volume3*0.001;


LHe_cc = [smallLHe_cc largeLHe_cc largestLHe_cc];
h_2 = h_large+h_small(end);
h_3 = h_2(end)+h_largest;
H = [h_small h_2 h_3];

figure(1)
plot(LHe_cc,peaks,'.-',LineWidth=1)
xlabel('LHe (cm^3)')
ylabel('Frequency (GHz)')
figure(2)
plot(H,peaks,'.-',LineWidth=1)
xlabel('h (distance from bulk in mm)')
ylabel('Frequency (GHz)')

