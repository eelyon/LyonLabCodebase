function [] = saveDataSubFolder(figObject,figName,subFolderName)
  dataPath = getDataPath();
  
  fileNum = getCurrentFileNum(dataPath);
  currentDateFolder = getCurrentDataFolder(dataPath);
  figName = [figName '_' num2str(fileNum)];
  subFolderPath = fullfile(currentDateFolder,subFolderName);
  
  if ~exist(subFolderPath,'dir')
     mkdir(currentDateFolder,subFolderName);
  end
  figName = [figName '.fig'];
  figPath = fullfile(subFolderPath,figName);
  saveas(figObject,figPath,'fig')

end

