function [num] = getCurrentFileNum()
    dataPath = getDataPath();
    fileNumPath = fullfile(dataPath,'fileNum.txt');
    fileNum = fopen(fileNumPath,'r+');
    num = fgetl(fileNum);
    fclose(fileNum);
end