% Get the current directory
currentDirectory = pwd;

% List all files in the current directory with a '.fig' extension
fileList = dir(fullfile(currentDirectory, '*.fig'));

% Initialize an empty cell array to store filenames
nameArr = cell(1, numel(fileList));

% Extract filenames from the file list and exclude those containing 'tVsTime'
for i = 1:numel(fileList)
    filename = fileList(i).name;
%     if ~contains(filename, 'tVsTime')
%         if ~contains(filename, 'Heating')
%             if ~contains(filename, 'Frequency')
%                 nameArr{i} = filename;
%             end
%         end
%     end
%    if (contains(filename, 'Frequency'))
    nameArr{i} = filename;
%    end
end

% Remove empty cells
nameArr(cellfun('isempty', nameArr)) = [];

% Iterate through the array of filenames
for i = 1:numel(nameArr)
    % Get the current file name
    filename = nameArr{i};
    
    unpack2Dfig(filename);
    %unpack2DfigTime(filename);
    pause(1);
end


function [] = unpack2Dfig(figName)
    fig = open(figName);

    % Get the handle of the subplot
    subplotHandleReal = subplot(2,3,4);
    subplotHandleImag = subplot(2,3,5);
    subplotHandleMag = subplot(2,3,6);
    
    % Get the handle of the plot in the first subplot
    lineHandleReal = findobj(subplotHandleReal, 'Type', 'errorbar');
    lineHandleImag = findobj(subplotHandleImag, 'Type', 'errorbar');
    lineHandleMag = findobj(subplotHandleMag, 'Type', 'errorbar');
    
    % Get the x and y data of the plot
    realXData = get(lineHandleReal, 'XData'); %assume all xData is the same
    realYData = get(lineHandleReal, 'YData');

    %imagXData = get(lineHandleImag, 'XData');
    imagYData = get(lineHandleImag, 'YData');

    %magXData = get(lineHandleMag, 'XData');
    magYData = get(lineHandleMag, 'YData');

    dater = [realXData(:), realYData(:), imagYData(:), magYData(:)];
    
    nameArray = strsplit(figName,'.');
    tag = char(nameArray(1));
    fileName = strcat(tag, '.csv');

    try
        writematrix(dater, fileName);
    catch
        writecell(dater, fileName);
    end
end

function [] = unpack2DfigTime(figName)
    fig = open(figName);

    % Get the handle of the subplot
    subplotHandleReal = subplot(2,3,1);
    subplotHandleImag = subplot(2,3,2);
    subplotHandleMag = subplot(2,3,3);
    
    % Get the handle of the plot in the first subplot
    lineHandleReal = findobj(subplotHandleReal, 'Type', 'scatter');
    lineHandleImag = findobj(subplotHandleImag, 'Type', 'scatter');
    lineHandleMag = findobj(subplotHandleMag, 'Type', 'scatter');
    
    % Get the x and y data of the plot
    realXData = get(lineHandleReal, 'XData'); %assume all xData is the same
    realYData = get(lineHandleReal, 'YData');

    %imagXData = get(lineHandleImag, 'XData');
    imagYData = get(lineHandleImag, 'YData');

    %magXData = get(lineHandleMag, 'XData');
    magYData = get(lineHandleMag, 'YData');

    dater = [realXData(:), realYData(:), imagYData(:), magYData(:)];
    
    nameArray = strsplit(figName,'.');
    tag = char(nameArray(1));
    fileName = strcat(tag, '.tcsv');

    writematrix(dater, fileName);
end