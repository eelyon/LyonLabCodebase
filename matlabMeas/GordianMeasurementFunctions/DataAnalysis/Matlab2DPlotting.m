whosePath = 'lab';
tag = 'NSD';

switch whosePath 
    case 'lab'
        path = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Conferences\APS March Meeting 2025 (LA)\Presentation_March2025\Images\';
    case 'gordian'
        path = 'C:\Users\gordi\Dropbox (Princeton)\GroupDropbox\Gordian\rfReflectometry\VNA measurements\HeLevelMeter_110623\11_10_23\';
    otherwise
        disp('Error! Choose existing path')
end

% Try and catch errors in loop
currentFigNum = 17307; %14813;
figPath = append(path,tag,'_',num2str(currentFigNum),'.fig');
fig = openfig(figPath,"invisible");
dataObjs = findobj(fig,'type','line');
yDat_new = dataObjs(1).YData;
xDat_new = dataObjs(1).XData;
close(fig);

figPath = append(path,'PSD_With_Device_v2','.fig');
fig = openfig(figPath,'invisible');
h = findall(gcf,'Type','line');
yDat_old = h(1).YData;
xDat_old = h(1).XData;
% yDat_rt = h(2).YData;
% xDat_rt = h(2).XData;
close(fig);

figure()
loglog(xDat_old,yDat_old,'b')
hold on
loglog(xDat_new,yDat_new,'r')
hold off
set(gca,'FontSize',14)
% legend('296 K','1.8 K')

xlabel('Frequency (Hz)','FontSize',15)
ylabel('NSD (nV/\surd{Hz})','FontSize',15)
xlim([1e3,xDat_old(end)])