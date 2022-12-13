function [num] = getCurrentFileNum(dataPath)
    fileNumPath = catFileAndFolders(dataPath,'fileNum.txt');
    fileNum = fopen(fileNumPath,'r+');
    num = fgetl(fileNum);
    fclose(fileNum);
end