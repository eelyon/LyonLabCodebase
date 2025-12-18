directory = 'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\';
day = '12_18_25\';
tag = 'Guard1';
% cd(directory)
% allFilesInDirectory = dir;
% figNum = 22880:1:23009; % 22028;

%maybe do thin where you enter the tag and then convert it
for figNum = 23460:1:23730
    try
        fig = openfig([directory,day,tag,'_',num2str(figNum),'.fig'],"invisible");
    catch
        warning(['Figure ', tag,'_',num2str(figNum), ' not found'])
        continue;
    end
    ax = findall(fig,'Type','Axes');
    
    % Prepare a structure to store data
    plotData = struct();
    plotData.timeConstant = fig.UserData.time_constant;
    plotData.filterOrder = fig.UserData.filter_order;
    plotData.demodRate = fig.UserData.demod_rate;
    try
        plotData.pollDuration = fig.UserData.poll_duration;
    catch
        warning('no poll duration in figure meta data')
    end
    plotData.controlDAC = fig.UserData.controlDAC;
    plotData.supplyDAC = fig.UserData.supplyDAC;
    
    
    for i = 1:length(ax)
        subplotData = struct();
        % Find all line objects within the subplot
        if isempty(findall(ax(i), 'Type', 'ErrorBar')) == 0
            lines = findall(ax(i), 'Type', 'ErrorBar');
            
            for j = 1:length(lines)
                subplotData(j).X = get(lines(j), 'XData');
                subplotData(j).Y = get(lines(j), 'YData');
                subplotData(j).Yerror = get(lines(j), 'YPositiveDelta');
            end
        else
            lines = findall(ax(i), 'Type', 'Line');
            for j = 1:length(lines)
                subplotData(j).X = get(lines(j), 'XData');
                subplotData(j).Y = get(lines(j), 'YData');
            end
        end
    %     lines = findall(ax(i), 'Type', 'ErrorBar');
        % Store each line’s X and Y data
    %     subplotData = struct();
    %     for j = 1:length(lines)
    %         subplotData(j).X = get(lines(j), 'XData');
    %         subplotData(j).Y = get(lines(j), 'YData');
    %         
    %         if isempty(get(lines(j), 'YPositiveDelta')) == 1
    %             continue
    %         else
    %             subplotData(j).Yerror = get(lines(j), 'YPositiveDelta');
    %         end
    %     end
        
        % Optional: get title, xlabel, ylabel, legend if needed
        subplotData(1).Title = get(get(ax(i), 'Title'), 'String');
        subplotData(1).XLabel = get(get(ax(i), 'XLabel'), 'String');
        subplotData(1).YLabel = get(get(ax(i), 'YLabel'), 'String');
        
        % Save subplot data into main structure
        plotData.(['subplot' num2str(i)]) = subplotData;
    end
    
    % Save the structure as a .mat file
    save([directory,day,tag,'_',num2str(figNum),'.mat'], 'plotData');
    
    % Close the figure
    close(fig);
end