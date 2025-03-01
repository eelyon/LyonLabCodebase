%% Replotting electron loading data from JLTP (2025)
path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Mayer\Single_Electron_Sensing\Figures\Figure_4\';
figPath = append(path,'NumEsLoaded_v2_no_Inset','.fig');
fig = openfig(figPath,"invisible");
ax = get(fig,'Children');
data = findobj(ax,'Type','ErrorBar');
numEs = [data(2).YData,data(1).YData(2:3)];
Vloads = [data(2).XData,data(1).XData(2:3)];
std = [data(2).YPositiveDelta,data(1).YPositiveDelta(2:3)];
% close(fig);

figure()
errorbar(Vloads,numEs,std,'r.');
set(gca,'FontSize',13)
xlabel('V_{load} (V)','FontSize',14)
ylabel('Number of Electrons','FontSize',14)
xlim([-0.12,1.02])
ylim([-4,280])

axes('Position',[.2 .6 .3 .3])
box on
errorbar(Vloads((end-2):end),numEs((end-2):end),std((end-2):end),'r.','MarkerSize',12)
set(gca,'FontSize',13)
xlim([-0.11,0.01])
ylim([-2.5,7])