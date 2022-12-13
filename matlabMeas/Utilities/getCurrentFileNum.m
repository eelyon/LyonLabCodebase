function [num] = getCurrentFileNum()
    dataPath = getDataPath();
    fileNumPath = catFileAndFolders(dataPath,'fileNum.txt');
    fileNum = fopen(fileNumPath,'r+');
    num = fgetl(fileNum);
    fclose(fileNum);
end