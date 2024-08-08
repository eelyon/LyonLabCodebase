function [fig,myFig] = plotData(xData,yData,varargin)
    defaultXLabel = 'x axis (arb)';
    defaultYLabel = 'y axis (arb)';
    defaultLegend = '';
    defaultColor = 'r.';
    defaultSubPlot = 0;
    defaultTurnHoldOn = 0;
    defaultType = 'linear';
    defaultTitle = '';
    defaultGrid = 'off';
    defaultMetaDat = '';
    defaultSaveMeta = 1;

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
    addParameter(p,'yError',@isnumeric); % Add errorbars
    addParameter(p,'title',defaultTitle,@isstring);
    addParameter(p,'grid',defaultGrid,@isnumeric);
    addParameter(p,'metaData',defaultMetaDat,@isstring);
    addParameter(p,'saveMeta',defaultSaveMeta,@isnumeric);
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
    elseif strcmp(p.Results.type,'loglog')
        fig = loglog(xData,yData,p.Results.color);
    elseif strcmp(p.Results.type,'semilogx')
        fig = semilogx(xData,yData,p.Results.color);
    elseif strcmp(p.Results.type,'errorbar') % Add errorbars
        fig = errorbar(xData,yData,p.Results.yError,p.Results.color);
    end

    ax = gca;
    ax.YGrid = p.Results.grid;
    ax.LineWidth = 1;
    ax.XMinorTick = 'on';
    ax.YMinorTick = 'on';

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
    if ~isempty(instrumentList) > 0
        for i = 1:length(instrumentList)
            if contains(instrumentList{i},"SR830")
                metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
            elseif contains(instrumentList{i},"controlDAC")
                metadata_struct.controlDAC = evalin('base',[instrumentList{i} '.channelVoltages;']);
            elseif contains(instrumentList{i},"supplyDAC")
                metadata_struct.supplyDAC = evalin('base',[instrumentList{i} '.channelVoltages;']);
%             elseif contains(instrumentList{i},"DoorLeft")
%                 metadata_struct.DoorLeft = evalin("base",strcat("query33220PulseWidth(",instrumentList{i},");"));
%             elseif contains(instrumentList{i},"DoorRight")
%                 metadata_struct.DoorRight = evalin("base",strcat("query33220PulseWidth(",instrumentList{i},");"));
            end
        end
        % Insert metadata structure into figure and save in data.
    end 
    myFig.UserData = metadata_struct;
    
end
