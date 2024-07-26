% Path = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_06_24\All_Amp_Transmission.fig';
% PathBackground = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMEas\Data\07_06_24\Baseline_Network_Analyzer.fig';
% 
% [backX,backY] = getXYData(PathBackground);
% fits = {};
% cutoffs = [];
% voltRatios = {};
% for i = 1:12
%     [testX,testY] = getXYData('C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_06_24\All_Amp_Transmission.fig','fieldNum',i);
%     delay(1);
%     correctY = testY+77-10;
%     voltRatio = [];
%     for j = 1:length(correctY)
%         voltRatio(j) = 10^(correctY(j)/20);
%     end
%     voltRatios{i} = voltRatio;
%     [dat,gof] = fitRollOff(testX,voltRatio);
%     display(dat.b);
%     fits{i} = dat;
% end

handles = [];
for i = 1:length(fits)
    if i == 1
        [handles(1),myFig] = plotData(testX,voltRatios{1},'holdOn',1,'color',"r.");
        plot(fits{1});
    else
        handles(i) = plot(testX,voltRatios{i});
        plot(fits{i});
    end
    
end

legend(handles);