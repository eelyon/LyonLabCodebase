whosePath = 'gordian';
tag = 'CorrectedRollOff';

switch whosePath 
    case 'lab'
        path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Conferences\APS March Meeting 2025 (LA)\Presentation_March2025\Images\';
    case 'gordian'
        path = 'C:\Users\gordi\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensitivity\data_single_electron_shuttling\09_18_25\';
    otherwise
        disp('Error! Choose existing path')
end

% Try and catch errors in loop
currentFigNum = 20391; %14813;
figPath = append(path,tag,'_',num2str(currentFigNum),'.fig');
fig = openfig(figPath,"invisible");
dataObjs = findobj(fig,'type','line');
yDat_fit = dataObjs(1).YData;
xDat_fit = dataObjs(1).XData;
yDat_s21 = dataObjs(2).YData;
xDat_s21 = dataObjs(2).XData;
close(fig);

% figPath = append(path,'PSD_With_Device_v2','.fig');
% fig = openfig(figPath,'invisible');
% h = findall(gcf,'Type','line');
% yDat_old = h(1).YData;
% xDat_old = h(1).XData;
% % yDat_rt = h(2).YData;
% % xDat_rt = h(2).XData;
% close(fig);

figure()
loglog(xDat_fit,yDat_fit*2,'-r')
hold on
loglog(xDat_s21,yDat_s21*2,'.b','MarkerSize',10)
hold off
set(gca,'FontSize',14)
legend('Fit','S_{21}')

xlabel('Frequency (Hz)','FontSize',15)
ylabel('Voltage Gain (arb. units)','FontSize',15)
xlim([1e3,xDat_s21(end)])