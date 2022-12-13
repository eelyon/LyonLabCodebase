function [monitors,screenArray] = getMonitors(method)
%GETMONITORS get all monitors data 
%[monitors,screenArray] = getMonitors()
%   monitors - rows corespond to screens position & size
%   obj      - Cell array of .Net screen objects (under windows)
screenArray = {};
% attempt to get all screens data using .Net
% the .Net returns correctly scaled positions & sizes
% as Windows scales the pixeles.
if nargin < 1 
    method = '.Net';
end
switch method
    case '.Net'
try
    NET.addAssembly('System.Windows.Forms');
    AS = System.Windows.Forms.Screen.AllScreens;
    
    for ii = 1:AS.Length
        monitors(ii,:) = double([AS(ii).Bounds.X, AS(ii).Bounds.Y,...
            AS(ii).Bounds.Width, AS(ii).Bounds.Height]);
        screenArray{ii} =  AS(ii);
    end
    % Otherwise use matlab's: get(0,'MonitorPositions')
catch err
    monitors = get(0,'MonitorPositions');
    screenArray = err;
end
    case 'matlab'        
        monitors = get(0,'MonitorPositions');
end
