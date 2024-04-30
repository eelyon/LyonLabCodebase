function [] = saveData(figObject,figName,varagin)
    switch nargin
        case 2 
            incrementFile = 1;
        case 3
            incrementFile = varagin;
    end
    
    figID   = genFigName(figName);
    figText = genFigText(figName);
    
    figPath = getFigPath(getCurrentDataFolder(),figID);
    addFigID(figObject,figText);
    saveas(figObject,figPath,'fig');
    if incrementFile
        incrementFileNum();
    end
end