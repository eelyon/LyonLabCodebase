clear;
closeAllFigures();
figureNumber = 645;
tau = 3000;
directory = ['C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\04_09_23\PSD_Shots_' num2str(figureNumber) '\filteredData'];
files = dir(directory);
phase = [];
shotNum = [];
for i = 1:(100)
    regex = ['*_' num2str(i) '_' num2str(figureNumber) '_filtered.fig'];
    directoryKeyVal = fullfile(directory,regex);
    figFiles = dir(directoryKeyVal);
    figNames = {figFiles.name};
    
    if ~isempty(figNames)
        shotNum(i) = i;
        figPath = fullfile(directory,figNames{1});
        phase(i) = analyze_PSD_Shot(figPath);
    end
end
fitted = figure(1);
fit = histfit(phase,24);
pd = fitdist(phase(:),'Normal');
[gaussX,gaussY] = generate_Gaussian(pd.mean,pd.sigma);

histFig = figure(800);
edges = linspace(-180,180,360/5+1);
h = histogram(phase,edges,'FaceColor','k');
scaleGauss = max(h.Values)/max(gaussY);
gaussY = gaussY*scaleGauss;
hold on;
plot(gaussX,gaussY,'r','LineWidth',1.25);
hold off;

xlabel('Phase (degrees)');
ylabel('Counts');
title(['Echo Time (\tau = ' num2str(tau) '\mus)']);
dim = [.175 .55 .3 .3];
annStr = {['\mu = ' num2str(pd.mean) char(176)],['\sigma = ' num2str(pd.sigma) char(176)]};
annotation('textbox',dim,'String',annStr,'FitBoxToText','on');
xTicks = [-180,-135,-90,-45,0,45,90,135,180];
xticks(xTicks);
saveas(histFig,fullfile(directory,['MMF_PSD_Histogram_' num2str(figureNumber) '.fig']),'fig');

