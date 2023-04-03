%% Parameters
folder = ['Cooldowns/' datestr(now(),'mm_dd_yy')];
if ~exist(folder,'dir')
  mkdir(folder)
  TimeInd = 1;
end
if exist('TimeInd','var')
  TimeIndStr = num2str(TimeInd,'%3.3d')
else
  TimeInd = 1;
  TimeIndStr = num2str(TimeInd,'%3.3d')
end
Extra = 'AllEmitterGates_20VBias_5VTf_n2FilPlate_0VOnIDCs_1p5_6p1_100ms';
titlestr = [folder, '/ScopeRead', TimeIndStr '_' Extra '_' num2str(now())];


TimeUnits = 1e-3;
xax = 'time [ms]';
YGain = 10^-7;
yax = 'Number of Electrons';

integrateStart = 15;
integrateEnd   = 150;

CutOffTime = -.005;
chans = [1,2];
saveBool = 1;

%% Data Acquisition
maxx = -inf;
minn = inf;
h = figure;
for chan = chans
    eval(['fprintf(eScope, ''DAT:SOU CH' num2str(chan) ''')']);
    fprintf(eScope, 'HEADER OFF');
    fprintf(eScope, 'DATA:ENC ASCII;WIDTH 2')
    
    recordLength = query(eScope, 'HOR:RECO?');
    fprintf(eScope, ['DATA:START 1;DATA:STOP ' recordLength]);
    
    yOffset = query(eScope, 'WFMP:YOFF?');
    xOffset = query(eScope,'WFMP:XZE?');
    xScale  = query(eScope,'WFMP:XIN?');
    verticalScale  = query(eScope,'WFMPRE:YMULT?');
    
    iStart = find(abs(range-integrateStart) < (range(2)-range(1))*.5);
    iEnd = find(abs(range-integrateEnd) < (range(2)-range(1))*.5);
    
    data = (str2double(verticalScale) * ((str2num(['[' query(eScope,'CURV?') ']' ])) - str2double(yOffset)));
    range = (((1:length(data)) * str2double(xScale)) + str2double(xOffset))/TimeUnits;
    avg = mean(data(1:find(range<CutOffTime,1,'last')));
    subplot(2,1,1)
    if chan == 1
        plot(range,data,'r')
       
    else
        plot(range,data,'b')
    end
    hold on
    
    
    
    %Plot
    subplot(2,1,2)
    if chan == 2
        rangeInt = range(iStart(1):iEnd(1));
        dataInt = data(iStart(1):iEnd(1));
        dataInt = cumtrapz(rangeInt*TimeUnits,dataInt-avg);
        dataInt = dataInt*YGain/(1.602e-19);
        plot(rangeInt,dataInt,'r')
        xlabel(xax);
        ylabel(yax);
    end
    
    
    xlim([rangeInt(1) rangeInt(end)])
    if maxx < max(dataInt)
        maxx = max(dataInt);
    end
    if minn > min(dataInt)
        minn = min(dataInt);
    end
    Zoom = (maxx-minn)/10;
    ylim([minn-Zoom maxx+Zoom])
    grid on;
    hold on;
end
hold off;
title(['Gain = ' num2str(YGain)])
subplot(2,1,1)
title(titleStr);
xlabel(xax);
ylabel('Volts [V]');
hold off;
grid on;

if saveBool == 1
    saveas(h,strcat(titlestr,'.fig'),'fig')
    TimeInd = TimeInd+1;
end