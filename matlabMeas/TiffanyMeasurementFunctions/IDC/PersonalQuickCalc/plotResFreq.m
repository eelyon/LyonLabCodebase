%% plot resonances

Folder     = append('Data\','12_07_23'); 
SweepIndex = 6931:1:6933;

figure()
for i = SweepIndex
    %% Read From Files
    File     = sprintf('*freqSweep_%i*.fig',i);
    S        = dir(fullfile(Folder,File));
    StmSweep = S.name;
     
    STMScan   = open([Folder '/' StmSweep]);     %load data to workspace
    close(STMScan)
    dataObjsX = findobj(STMScan,'-property','XData');
    dataObjsY = findobj(STMScan,'-property','YData');
    
    frequency = dataObjsX(2).XData;
    power     = dataObjsX(2).YData;

    plot(frequency,power)
    hold on
end
