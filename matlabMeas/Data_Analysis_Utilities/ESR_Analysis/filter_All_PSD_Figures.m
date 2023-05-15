figureNumber = 645;
directoryToFilter = ['C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\04_09_23\PSD_Shots_' num2str(figureNumber)];
numFilesToFilter = 100;
LPFilter = 0.5e6;

files = dir(directoryToFilter);
phase = [];
shotNum = [];
for i = 1:(numFilesToFilter)
    regex = ['*_' num2str(i) '_' num2str(figureNumber) '.fig'];
    directoryKeyVal = fullfile(directoryToFilter,regex);
    figFiles = dir(directoryKeyVal);
    figNames = {figFiles.name};
    
    if ~isempty(figNames)
        filterPSDIQSignals(directoryToFilter,figNames{1},LPFilter);
    end
end