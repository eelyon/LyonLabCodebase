function [] = saveData(figObject,figName)
    dataPath = getDataPath()
    dateFormat = 'mm_dd_yy';
    
    fileNum = getCurrentFileNum(dataPath)
    figName = getFigPath(getCurrentDataFolder(dataPath,dateFormat),[figName '_' num2str(fileNum)]);
    saveas(figObject,figName,'fig')
    incrementFileNum();
end