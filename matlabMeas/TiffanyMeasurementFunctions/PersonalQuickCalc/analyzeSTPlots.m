
%% Options
Folder     = append('Data\','12_08_23'); 
SweepIndex = 7096:3:7111;

h1 = figure;
hold on
%% Read From Files
for i=SweepIndex
    File     = sprintf('*Pinchoff_%i*.fig',i);
    S        = dir(fullfile(Folder,File));
    StmSweep = S.name;
     
    STMScan   = open([Folder '/' StmSweep]);     %load data to workspace
    dataObjsX = findobj(STMScan,'-property','XData');
    dataObjsY = findobj(STMScan,'-property','YData');
    
    VSTMbefore = dataObjsX(4).XData;
    Ibefore    = dataObjsX(4).YData;
    close(STMScan)
    xlabel('V_{barrierE} [V]');
    ylabel('I_{outE} [nA]');
    set(gcf,'color','w');
    set(gca,'FontWeight','bold');
    legendName = num2str(i);
    plot(VSTMbefore,-Ibefore,'-o','Linewidth',2,'Markersize',4,'DisplayName',legendName)
    ax=gca; 
    ax.YAxis.Exponent = -9;
    legend('show')
    grid on
end
hold off
figure(h1)