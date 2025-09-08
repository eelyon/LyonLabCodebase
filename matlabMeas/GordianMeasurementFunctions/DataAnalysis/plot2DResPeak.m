
figNums = [20074:20077 20095 20098 20110:20112 20117:20131];
peaks = [];

numFigs = length(figNums);

for i=0:numFigs-1
    currentFigNum = figNums(i+1);
    [currentFigMetaData,figHandle] = displayFigNum(currentFigNum,'visibility',0);
    closeFigure(figHandle);
    pause(0.02);  % need this pause for code to work the first time, waits for figures to close
    
    figPathCell = findFigNumPath(currentFigNum);
    figPath = figPathCell{1};
    [xDat,yDat] = getXYData(figPath,'Type','line','FieldNum',2);
    [pks,loc] = findpeaks(-yDat,'MinPeakProminence',1);
    peaks(i+1) = xDat(loc)
end

r_small = 4.064; % in mmm
small_h = [0 1.5 3 4 5 5.1]; % in mm
small_V = pi*r_small^2*small_h; % in mm3
small_total = small_V(end);
smallLHe_cc = small_V*0.001;

r_large = 27.305; % in mm
big_h = [1 2 3 3.2 3.4 3.5 3.55 3.6 3.7 3.75 3.8 3.85 3.9 4 4.2 4.4 4.6 4.8]; % in mm
big_V = pi*r_large^2*big_h; % in mm3
bigLHe_cc = (big_V+small_total)*0.001;

LHe_cc = [smallLHe_cc bigLHe_cc];


figure(1)
plot(LHe_cc,peaks,'.-',LineWidth=1)
xlabel('LHe (cm^3)')
ylabel('Frequency (GHz)')