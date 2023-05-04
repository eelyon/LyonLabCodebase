function [ dataFolderCellArray] = getSubDataFolders( parentFolderPath )
  files = dir(parentFolderPath);
  dirFlags = [files.isdir];
  subFolders = files(dirFlags);
  dataFolderCellArray = {subFolders(3:end).name};
end

