function [fig] = plot2DData(xData,yData,cData,varargin)
    defaultXLabel = "x axis (arb)";
    defaultYLabel = "y axis (arb)";
    defaultCLabel = "color axis (arb)";
    defaultSubPlot = 0;
    defaultTurnHoldOn = 0;
    defaultType = 'plot';
    defaultTitle = '';

    % Parse optional arguments
    p = inputParser;
    addRequired(p,'xData',@isnumeric);
    addRequired(p,'yData',@isnumeric);
    addRequired(p,'cData');
    addParameter(p,'xLabel',defaultXLabel,@isstring);
    addParameter(p,'yLabel',defaultYLabel,@isstring);
    addParameter(p,'cLabel',defaultCLabel,@isstring);
    addParameter(p,'holdOn',defaultTurnHoldOn,@isnumeric);
    addParameter(p,'type',defaultType,@isstring);
    addParameter(p,'title',defaultTitle,@isstring);
    parse(p,xData,yData, cData,varargin{:});
    
    % Plot figure with optional arguments, defaults if arguments are not 
    % provided. (See above)
    h = findobj('type','figure');
    myFig = figure(h(1));

    fig = image(xData, yData, cData, 'CDataMapping', 'scaled');

    if p.Results.holdOn
        hold on;
    else
        hold off;
    end
    
    xlabel(p.Results.xLabel);
    ylabel(p.Results.yLabel);
    title(p.Results.title);
    c = colorbar;
    c.Label.String = p.Results.cLabel;
    c.Label.Rotation = 270;
    c.Label.FontSize = 12;
    c.Label.Position = [2.5,7];

    % Compile Metadata
    figDateFormat = 'mm_dd_yy HH:MM:SS';
    metadata_struct.time= datestr(now(),figDateFormat);
    instrumentList = parseInstrumentList();

%     for i = 1:length(instrumentList)
%         if contains(instrumentList{i},"SR830")
%             metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
%         elseif contains(instrumentList{i},"DAC")
%             metadata_struct.sigDAC = evalin('base',['sigDACGetConfig(' instrumentList{i} ');']);
%         elseif contains(instrumentList{i},"VmeasC")
%                 metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
%         elseif contains(instrumentList{i},"VmeasE")
%             metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
%         end
%     end
    
    % Insert metadata structure into figure and save in data.

    myFig.UserData = metadata_struct;
end
