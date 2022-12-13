function [filesInFolder] = getFileTypeInFolder(folderPath,fileType)
    if ~exist(folderPath,'dir')
        error(['Folder ', folderPath, ' does not exist']);
    end

    filesInFolder = dir([folderPath, '/*', fileType]);
   
end