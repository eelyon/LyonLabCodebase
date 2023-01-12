function [] = displayFigNums(figNumArr,monitor)
% Function displays multiple figures over a desired monitor.
%
% displayFigNums(figNumArr) - will default to monitor 1.
% displayFigNums(figNumArr,monitor) - will spread to monitor.
%
% Inputs:
%       figNumArr - array of figure numbers to display.
%       monitor - integer denoting the monitor to spread to.
    if nargin == 1
        spreadToMonitor = 1;
    else
        spreadToMonitor = monitor;
    end
    handleArr = [];
    monitorArr = [];
    for i = 1:length(figNumArr)
        [metaDat,figHandle] = displayFigNum(figNumArr(i));
        handleArr(i) = figHandle;
        monitorArr(i) = spreadToMonitor;
    end

    spreadFigures(handleArr,monitorArr);
end

