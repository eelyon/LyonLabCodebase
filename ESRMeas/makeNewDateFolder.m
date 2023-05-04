function [] = makeNewDateFolder(path)
  if ~exist(path,'dir')
    mkdir(path);
    disp(['Created new Data Folder under: ', path ' \n']);
  end
  
  fileNumPath = fullfile(path,'fileNum.txt');
  
  if ~exist(fileNumPath,'file')
     fileNum = fopen(fileNumPath,'a+');
     fprintf(fileNum,'%d\n',1);
     fclose(fileNum);
     disp(['Created new fileNum.txt under: ', fileNumPath ' \n']);
  end
  
  dateString = datestr(now(),'mm_dd_yy');
  [success,message,messageID] = mkdir(path,dateString);
  if(success == 0)
    error(message,messageID);
  end
  
end

