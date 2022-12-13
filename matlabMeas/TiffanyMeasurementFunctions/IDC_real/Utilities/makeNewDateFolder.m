function [] = makeNewDateFolder(path,format)
    if nargin < 1
        format = 'mm_dd_yy';
        path = [pwd '\Data\'];
    end
    if nargin < 2
        format = 'mm_dd_yy';
    end
        
    if ~exist(path,'dir')
        mkdir(path);
        disp(['Created new Data folder under: ' path])
    end
    fileNumPath = catFileAndFolders(path,'fileNum.txt');
    
    if ~exist(fileNumPath,'file')
        fileNum = fopen(fileNumPath,'a+');
        fprintf(fileNum,'%d\n', 1);
        fclose(fileNum);
        disp(['Created a new fileNum.txt file in: ' fileNumPath] )
    end

    dateString = datestr(now(),format);
    [success,message,messageID] = mkdir(path,dateString);
    if(success == 0)
        error(message,messageID)
    end
    datePath = catFileAndFolders(path,dateString);
    

end