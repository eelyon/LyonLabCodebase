path = 'C:\Users\Lyon-Lab-B417\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\';
figPath = append([path, '11_05_25\'],tag,'_',num2str(21774),'.fig');

fig = openfig(figPath,"invisible");
ax = get(fig,'Children');

axis1 = findobj(ax(1),'Type','ErrorBar');
y1 = axis1.YData;
x1 = axis1.XData;

axis2 = findobj(ax(2),'Type','ErrorBar');
y2 = axis2.YData;
x2 = axis2.XData;

axis3 = findobj(ax(3),'Type','ErrorBar');
y3 = axis3.YData;
x3 = axis3.XData;

axis4 = findobj(ax(4),'Type','ErrorBar');
y4 = axis4.YData;
x4 = axis4.XData;

figure()
plot(x1,y1);
hold on
plot(x2,y2);
% plot(x3,y3);
plot(x4,y4);
hold off
legend('1','2','3','4');
