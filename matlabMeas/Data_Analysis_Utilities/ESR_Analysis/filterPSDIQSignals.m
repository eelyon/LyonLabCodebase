function [] = filterPSDIQSignals(folderPath,figName,cutoffFreq)
    filterFolder = fullfile(folderPath,'filteredData');
    
    if ~exist(filterFolder,'dir')
        mkdir(filterFolder);
    end
    
    originalPath = fullfile(folderPath,figName);

    [QxDat,QyDat] = getXYData(originalPath,'fieldNum',1);
    [IxDat,IyDat] = getXYData(originalPath,'fieldNum',2);

    filterQ = filter_signal(QxDat,QyDat,cutoffFreq);
    filterI = filter_signal(IxDat,IyDat,cutoffFreq);

    filteredDat = figure(800);
    plot(QxDat,filterQ,'b');
    hold on;
    plot(IxDat,filterI,'g');
    hold off;
    xlabel('Time (s)');
    ylabel('ESR Signal (a.u)');
    legend({'Filtered Q','Filtered I'},'Location','NorthWest');
    title(['Filtered Hahn Echo, ' num2str(cutoffFreq) ' Hz LPF']);
    saveas(filteredDat,fullfile(filterFolder,[figName(1:length(figName)-4) '_filtered.fig']),'fig');
end