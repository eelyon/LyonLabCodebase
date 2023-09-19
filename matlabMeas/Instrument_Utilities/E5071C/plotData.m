function [fig,figHandle] = plotData(xData,yData,varargin)
    defaultXLabel = 'x axis (arb)';
    defaultYLabel = 'y axis (arb)';
    defaultLegend = '';
    defaultColor = 'rO';
    defaultSubPlot = 0;
    defaultHoldOn = 0;
    defaultTitle = '';
    
    % Parse optional arguments
    p = inputParser;
    addRequired(p,'xData',@isnumeric);
    addRequired(p,'yData',@isnumeric);
    addParameter(p,'xLabel',defaultXLabel,@ischar);
    addParameter(p,'yLabel',defaultYLabel,@ischar);
    addParameter(p,'legend',defaultLegend,@ischar);
    addParameter(p,'color',defaultColor,@ischar);
    addParameter(p,'subPlot',defaultSubPlot,@isnumeric);
    addParameter(p,'holdOn',defaultHoldOn,@isnumeric);
    addParameter(p,'Title',defaultTitle,@ischar);
    parse(p,xData,yData,varargin{:});
    
    % Plot figure with optional arguments, defaults if arguments are not 
    % provided. (See above)
    h = findobj('type','figure');
    totNumFigures = length(h)+1;
    figWidth = 600;
    figHeight = 500;
    if ~p.Results.subPlot
        figHandle = figure(totNumFigures);
        %bring_figure_front(figHandle,totNumFigures);
        %figHandle.Position = [(totNumFigures-1)*(figWidth-figWidth*floor(1/4)),figHeight-figHeight*floor(totNumFigures/4),figWidth,figHeight];
    end
    
    fig = plot(xData,yData,p.Results.color);
    
    if p.Results.holdOn
      hold on;
    else
      hold off;
    end
    handle = ancestor(fig,'figure');

    xlabel(p.Results.xLabel);
    ylabel(p.Results.yLabel);
    title(p.Results.Title);
    if ~strcmp(p.Results.legend,'')
        legend(p.Results.legend,'Location','northeast');
    end
    % Compile Metadata
    figDateFormat = 'mm_dd_yy HH:MM:SS';
    %metadata_struct.time= datestr(now(),figDateFormat);

    % Insert metadata structure into figure and save in data.
    %fig.UserData=metadata_struct;
end


function bring_figure_front(plotHandle,totalFigNum)
    handleNum = plotHandle.Number;
    Pix_SS = get(0,'screensize');

    x_len=560/(6/5);
    y_len=420/(6/5);
    x_position= (x_len-1/15*x_len)*(totalFigNum-1);
    y_position= y_len*(totalFigNum-1);
    

    H1=sfigure(handleNum);
    if x_position+x_len<Pix_SS(3)
        x_position=x_position+(x_len-1/15*x_len);
    else
        x_position=0;
        if y_position==0 || y_position+2*y_len<Pix_SS(4)
            y_position=y_position+y_len;
        else
            y_position=y_position-y_len/2;
        end
    end
    set(H1,'Position',[x_position,y_position,x_len,y_len]);
end



function h = sfigure(h)
% In Windows, MATLAB R14's FIGURE behaviour can be annoying.
% Namely, whenever we invoke figure/figure(X), it immediately jumps to the foreground, 
% and steals focus from whatever other window was active,
% preventing you from switching to other processes, the MATLAB editor window, etc... 
% (if you are repeatedly switching between figures/displaying results in a loop).
% This wrapper to figure makes FIGURE silent -- ie. if you had figure X in the background,
% then the call figure(X) will keep that figure in the background.
% SFIGURE  Create figure window (minus annoying focus-theft).
%
% Usage is identical to figure.
%
% Daniel Eaton, 2005
%
% See also figure
if nargin>=1 
	if ishandle(h)
		set(0, 'CurrentFigure', h);
	else
		h = figure(h);
	end
else
	h = figure;
end
end
