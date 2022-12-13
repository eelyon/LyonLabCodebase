function [varargout]  = spreadFigures(figs, assignToScreen)
% SPREADFIGURES()
% SPREADFIGURES(figs, assignToScreen)
% SPREADFIGURES([], [])
% SPREADFIGURES(figs, 'other')
% [config] = SPREADFIGURES(...)
% SPREADFIGURES(config)
% spread figures accross multiple monitors
%
% figs           : Either figure handle array, or indecies of currently open figures.
% assignToScreen : Either a screen index vector, the same length as 'figs'.
%                   or - indecies of screens to use (automatic assignment to screen).
%                   or - 'other'.
% 'other' - Uses the screens NOT currently occupied by Matlab Desktop.
% [config] = SPREADFIGURES(...) - additionaly, returns the spread configuration for later re-use:
% SPREADFIGURES(config)         - reinstates figures to saved configuration.
%
% Elimelech Schreiber 21/01/2019
if nargin < 1 || isempty(figs)
    figHandle = findobj('Type','figure');
    if isempty(figHandle)
        return
    end
    figHandle = sortFigureHandles(figHandle);
    figs = 1:length(figHandle);
elseif isnumeric(figs) && ~isempty(figs)   %figure indices
    figHandle = findobj('Type','figure');
    if isempty(figHandle)
        warning('No figures. Go figure...');
        return
    end
    figHandle = sortFigureHandles(figHandle);
    %h = ceil(h(h>0 & h <= length(figHandle))); % try to avoid errors
elseif isstruct(figs)
    config = spreadFigsConfig(figs);
    if nargout > 0
        varargout{1} = config;
    end
    return
else
    figHandle = figs;
    figs = 1:length(figHandle);
end
monitors       = getMonitors();
Nmonitors      = size(monitors,1);
monitorIndx    = 1:Nmonitors;
Nfigs          = length(figs);
if nargin > 1
    if (ischar(assignToScreen) || isStringScalar(assignToScreen))
        if strcmpi(assignToScreen,'other')
            mms = getMatlabMainScreen();
            monitorIndx = setdiff(monitorIndx,mms);
            Nmonitors   = length(monitorIndx);
            monitors    = monitors(monitorIndx,:);
            assignToScreen    = [];
        else
            error(['Unrecognized ''assignToScreen'' command: ''', assignToScreen,'''']);
        end
    elseif length(assignToScreen) < min(Nfigs,Nmonitors) && max(assignToScreen) <= Nmonitors &&...
            length(unique(assignToScreen)) == length(assignToScreen) %(is unique)
        %use these monitors
        Nmonitors   = length(assignToScreen);
        monitorIndx = assignToScreen;
        monitors    = monitors(monitorIndx,:);
        assignToScreen    = [];
    elseif length(assignToScreen) ~= Nfigs
        error('Length of assignToScreen mismatch.');
    end
end
if nargin < 2 || isempty(assignToScreen)
    % assign more to bigger screens:  
    relativeArea    = (monitors(:,3) .* monitors(:,4))';
    relativeArea    = relativeArea / sum(relativeArea);
    nFigsPerMonitor = floor(relativeArea * Nfigs);
    remain          = Nfigs - sum(nFigsPerMonitor);
    % assign remainder to screens where area will be maximized:
    while remain
        areaPerFig     = relativeArea ./ (nFigsPerMonitor + 1);
        [~, bestAreaScreen] = sort(areaPerFig, 'descend');
        nFigsPerMonitor(bestAreaScreen(1)) = nFigsPerMonitor(bestAreaScreen(1)) + 1;
        remain = remain - 1;
    end
    %assign range of figs for each screen
    FigsForMonitor = [0, cumsum(nFigsPerMonitor)];
    assignToScreen  = zeros(1, Nfigs);
    for iMon = 1 : Nmonitors
        assignToScreen((FigsForMonitor(iMon) + 1) : FigsForMonitor(iMon + 1)) = monitorIndx(iMon);
    end
end
config.monitorIndx    = monitorIndx;
config.assignToScreen = assignToScreen;
config.figHandle      = figHandle;
config.figs           = figs;
config = spreadFigsConfig(config);
if nargout > 0
    varargout{1} = config;
end
end
function config = spreadFigsConfig(config)
%call TileFigures seperately for each screen
for iMon = config.monitorIndx
    logIndex = config.assignToScreen == iMon;
    if any(logIndex)
        if isfield(config,'config') && length(config.config) >=iMon
            tileFigures(config.config{iMon});
        else
            config.config{iMon} = tileFigures(config.figHandle(config.figs(logIndex(1:length(config.figs)))), [], [], iMon);
        end
    end
end
end
function figSorted = sortFigureHandles(figs)
[~, idx] = sort([figs.Number]);
figSorted = figs(idx);
end
