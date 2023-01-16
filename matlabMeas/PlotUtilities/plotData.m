function [fig] = plotData(xData,yData,varargin)
    defaultXLabel = 'x axis (arb)';
    defaultYLabel = 'y axis (arb)';
    defaultLegend = '';
    defaultColor = 'rO';
    defaultSubPlot = 0;
    defaultTurnHoldOn = 0;
    defaultType = 'plot';
    defaultTitle = '';

    % Parse optional arguments
    p = inputParser;
    addRequired(p,'xData',@isnumeric);
    addRequired(p,'yData',@isnumeric);
    addParameter(p,'xLabel',defaultXLabel,@isstring);
    addParameter(p,'yLabel',defaultYLabel,@isstring);
    addParameter(p,'legend',defaultLegend,@isstring);
    addParameter(p,'color',defaultColor,@isstring);
    addParameter(p,'subPlot',defaultSubPlot,@isnumeric);
    addParameter(p,'holdOn',defaultTurnHoldOn,@isnumeric);
    addParameter(p,'type',defaultType,@isstring);
    addParameter(p,'title',defaultTitle,@isstring);
    parse(p,xData,yData,varargin{:});
    
    % Plot figure with optional arguments, defaults if arguments are not 
    % provided. (See above)
    h = findobj('type','figure');
    if p.Results.subPlot
        myFig = figure(h);
    else
        if isempty(h)
            newFigNum = 1;
        else
            newFigNum = get(gcf,'Number') + 1;
        end
        myFig = figure(newFigNum);
    end
    

    fig = plot(xData,yData,p.Results.color);
    
    if p.Results.holdOn
        hold on;
    else
        hold off;
    end
    
    xlabel(p.Results.xLabel);
    ylabel(p.Results.yLabel);
    title(p.Results.title);
    if ~strcmp(p.Results.legend,'')
        legend(p.Results.legend,'Location','northeast');
    end
    % Compile Metadata
    figDateFormat = 'mm_dd_yy HH:MM:SS';
    metadata_struct.time= datestr(now(),figDateFormat);
    instrumentList = parseInstrumentList();

    for i = 1:length(instrumentList)
        if contains(instrumentList(i),"SR830")
            metadata_struct.SR830 = evalin('base',['getSR830State(' instrumentList(i) ';']);
        elseif contains(instrumentList(i),"sigDAC")
            metadata_struct.sigDAC = evalin('base',['sigDACGetConfig(' instrumentList(i) ',8);']);
        end
    end
    
    % Insert metadata structure into figure and save in data.

    myFig.UserData = metadata_struct;
end
