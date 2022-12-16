function [xDat, yDat] = getXYData(figPath,fieldNum,dataType)
    % function gets the X and Y data from a figure. 
    % Parameters: path - full path to .fig file
    %             fieldNum - the desired plot number whose data you want to pull
    %                        in the case of subplots it goes in reverse order 
    %                        (e.g. subplot 5 of 6 subplots is fieldNum 2) 
    %             dataType - The type of data to look for such as 'Line' or
    %                        'ErrorBar'
    
    fig = openfig(figPath,'invisible');
    h = findobj(fig,'Type',dataType);
    xDat = h(fieldNum).XData;
    yDat = h(fieldNum).YData;
end