function [figMetaData,fig] = displayFigNum(figNum,varargin)
    % Displays a .fig file of the format "figName_Number.fig" in its own
    % figure and returns the UserData and figure handle associated with 
    % the figure number. Searches only the /Data folder and displays all
    % figures with this number.
    % 
    % INPUTS: figNum - numeric number for the targeted figure.
    %         'visibility' - optional numeric parameter that turns the
    %         visibility on (1 default) or off (0).
    
    defaultVisibility = 1;
    
    % Parse optional arguments
    p = inputParser;
    addRequired(p,'figNum',@isnumeric);
    addParameter(p,'visibility',defaultVisibility,@isnumeric);
    parse(p,figNum,varargin{:});
    
    if p.Results.visibility
        vis = 'visible';
    else
        vis = 'invisible';
    end
    figPaths = findFigNumPath(figNum);
    figMetaData = {};
    for i = 1:length(figPaths)
        fig = openfig(figPaths{i},'reuse',vis );
        figMetaData{i} = fig.UserData;
    end
    
end