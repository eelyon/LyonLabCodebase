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

    writematrix(dater, fileName);
end