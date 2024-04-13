function [fig,myFig] = plotData(xData,yData,varargin)
    defaultXLabel = 'x axis (arb)';
    defaultYLabel = 'y axis (arb)';
    defaultLegend = '';
    defaultColor = 'ro';
    defaultSubPlot = 0;
    defaultTurnHoldOn = 0;
    defaultType = 'plot';
    defaultTitle = '';
    defaultGrid = 'off';
    defaultMetaDat = '';
    % Parse optional arguments
    p = inputParser;
    addRequired(p,'xData',@isnumeric);
    addRequired(p,'yData',@isnumeric);
    addParameter(p,'xLabel',defaultXLabel,@isstring);
    addParameter(p,'yLabel',defaultYLabel,@isstring);
    addParameter(p,'legend',defaultLegend,@ischar);
    addParameter(p,'color',defaultColor,@isstring);
    addParameter(p,'subPlot',defaultSubPlot,@isnumeric);
    addParameter(p,'holdOn',defaultTurnHoldOn,@isnumeric);
    addParameter(p,'type',defaultType,@isstring);
    addParameter(p,'title',defaultTitle,@isstring);
    addParameter(p,'grid',defaultGrid,@isnumeric);
    addParameter(p,'metaData',defaultMetaDat,@isstring);
    parse(p,xData,yData,varargin{:});
    
    % Plot figure with optional arguments, defaults if arguments are not 
    % provided. (See above)
    h = findobj('type','figure');
    if p.Results.subPlot
        myFig = figure(h(1));
    else
        newFigNum = getNextMATLABFigNum();
        myFig = figure(newFigNum);
    end
    
    if strcmp(p.Results.type,'linear')
        fig = plot(xData,yData,p.Results.color);
    elseif strcmp(p.Results.type,'semilogy')
        fig = semilogy(xData,yData,p.Results.color);
    end

    if p.Results.grid
        ax = gca;
        ax.YGrid = 'on';
    end
    
    
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
    metadata_struct.metaData = p.Results.metaData;
    instrumentList = parseInstrumentList();
    save = 0;
    if length(instrumentList) > 1 && save ==1
        for i = 1:length(instrumentList)
            if contains(instrumentList{i},"SR830")
                metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
            elseif contains(instrumentList{i},"DAC")
                metadata_struct.sigDAC = evalin('base',[instrumentList{i} '.channelVoltages;']);
            elseif contains(instrumentList{i},"VmeasC")
                metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
            elseif contains(instrumentList{i},"VmeasE")
                metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
            end
        end
        % Insert metadata structure into figure and save in data.
    end 
    myFig.UserData = metadata_struct;
    
end
