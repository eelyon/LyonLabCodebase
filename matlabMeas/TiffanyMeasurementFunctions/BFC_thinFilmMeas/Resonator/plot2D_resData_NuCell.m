%figNums = [433 440 447 450 459 462 468 470 476 478 484 486]; % bottom PCB
figNums = [436 442 445 453 456 464 466 472 474 480 482 488]; % top PCB
peaks = [];

numFigs = length(figNums);

for i=0:numFigs-1
    currentFigNum = figNums(i+1);
    [currentFigMetaData,figHandle] = displayFigNum(currentFigNum,'visibility',0);
    closeFigure(figHandle);
    pause(0.02);  % need this pause for code to work the first time, waits for figures to close
%     
    % path_home = 'C:\Users\LyonLab\Documents\GitHub\LyonLabCodebase\matlabMeas\TiffanyMeasurementFunctions\HeLevelResonatorData_07_26\';
    % tag = 'HeLevelMeter';
    % figPath = append(path_home,tag,'_',num2str(currentFigNum),'.fig');
    figPathCell = findFigNumPath(currentFigNum);
    figPath = figPathCell{1};
    [xDat,yDat] = getXYData(figPath,'Type','line','FieldNum',2);
%     [pks,loc] = findpeaks(-yDat,'MinPeakProminence',1);
    [~,min_idx] = min(yDat);
    peaks(i+1) = xDat(min_idx);
end

atm_added = [0 0.5 1 1.5 2 2.5 3 4 5 6 7 8];
H = 1.153*atm_added;
volume = pi*(0.19685)^2*H; % in mm
LHe_cc = volume*0.001; % mm3 to cc


figure(1)
plot(LHe_cc,peaks*1e3,'.-',LineWidth=1)
xlabel('LHe (cm^3)')
ylabel('Frequency (GHz)')
title('Bottom Resonator')
figure(2)
plot(H,peaks,'.-',LineWidth=1)
xlabel('h (distance from bulk in mm)')
ylabel('Frequency (GHz)')

