function [] = saveCPMGShots(figObject,numEchoes,echoNum)
  
  dataPath = getDataPath();
  figNum = getCurrentFileNum(dataPath);
  currentDateFolder = getCurrentDataFolder(dataPath);
  
  CPMGFolderName = ['CPMG_' num2str(figNum) '_' num2str(numEchoes)];
  echoFigName = [CPMGFolderName '_echo_' num2str(echoNum)];
  echoFolderPath = fullfile(currentDateFolder,CPMGFolderName);
  
  if ~exist(echoFolderPath,'dir')
    mkdir(currentDateFolder,CPMGFolderName);
  end
  
  figPath = fullfile(echoFolderPath,echoFigName);
  saveas(figObject,figPath,'fig');
end

