function [currentFolder] = getCurrentDataFolder(path)
  dateString = datestr(now(),'mm_dd_yy');
  currentFolder = [path '\' dateString];
  if ~exist(currentFolder,'dir');
    mkdir(path,dateString);
  end
  
end

