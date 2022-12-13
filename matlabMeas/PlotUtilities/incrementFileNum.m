function [] = incrementFileNum()
    dataPath = getDataPath();
    currentNum = str2num(getCurrentFileNum());
    fileNumPath = catFileAndFolders(dataPath,'fileNum.txt');
    fileNum = fopen(fileNumPath,'w');
    fprintf(fileNum,'%d\n',currentNum+1);
    fclose(fileNum);
end