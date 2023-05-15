function [] = saveData(figObject,figName,varagin)
  dataPath = getDataPath();
  switch nargin
    case 2
      incrementFile = 1;
    case 3
      incrementFile = 0;
  end
  
  fileNum = getCurrentFileNum(dataPath);
  currentDateFolder = getCurrentDataFolder(dataPath);
  figName = [figName '_' num2str(fileNum)];
  figPath = getFigPath(currentDateFolder,figName);
  saveas(figObject,figPath,'fig');
  if incrementFile
    incrementFileNum();
  end
end

