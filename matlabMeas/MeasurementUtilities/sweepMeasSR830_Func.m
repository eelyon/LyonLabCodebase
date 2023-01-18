function [] = sweepMeasSR830_Func(plotHandles,sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,device,port,doBackAndForth)
%initializeSR830Meas1D;
%% Parameters to probe
if start > stop && deltaParam > 0
    deltaParam = -1*deltaParam;
elseif start < stop && deltaParam < 0
    deltaParam = -1*deltaParam;
end

paramVector = start:deltaParam:stop;

%% SR830 to read. Note that the name must exist in the base workspace!
readSR830 = device;

%% Create all arrays for data storage. 
[Real,Imag,Mag,time,avgParam,avgmags,avgxs,avgys,stdm,stdx,stdy] = deal(inf);

%% Halfway point in case back and forth is done.
halfway = length(paramVector)/2;

%% Index for time axis.
currentTimeIndex = 1;
currentAvgIndex = 1;
%% 95% confidence interval vector.
CIVector = tinv([0.025 0.975], repeat-1); 
errorType = 'CI';

%% Define a cleanup function that will save data on user interrupt.
startTime = now();

%% Main parameter loop.
for value = paramVector
    %setVal(device,port,value);

    %DACGUI.updateDACGUI;
    %drawnow;
    
    %% Initialize average vectors that gets reset for the repeating for loop
    magVectorRepeat = [];
    xVectorRepeat = [];
    yVectorRepeat = [];
    
    %% Repeating for loop - changing repeat increases the number of averages to perform per point.
    for j = 1:repeat
        
        %% Query SR830 for Real/Imag data, calculate Magnitude and place in vectors
        [Real,Imag,Mag,time] = getSR830Data(Real,Imag,Mag,time,currentTimeIndex,startTime,timeBetweenPoints,readSR830);
        
        %% Place data in repeat vectors that get averaged and error bars get calculated.
        magVectorRepeat(j)  = Mag(currentTimeIndex);
        xVectorRepeat(j)    = Real(currentTimeIndex);
        yVectorRepeat(j)    = Imag(currentTimeIndex);

        %% Place time data in time array.
        currentTimeIndex = currentTimeIndex + 1;
        updateSR830TimePlots(plotHandles,Real,Imag,Mag,time);
    end

    %% Average all data and place in average arrays.
    avgParam(currentAvgIndex)   = value;
    avgmags(currentAvgIndex)    = mean(magVectorRepeat);
    avgxs(currentAvgIndex)      = mean(xVectorRepeat);
    avgys(currentAvgIndex)      = mean(yVectorRepeat);
    
    %% Calculate error bars for each point using the repeat vectors.
    stdm(currentAvgIndex)   = calculateErrorBar(errorType,CIVector,magVectorRepeat,repeat);
    stdx(currentAvgIndex)   = calculateErrorBar(errorType,CIVector,xVectorRepeat,repeat);
    stdy(currentAvgIndex)   = calculateErrorBar(errorType,CIVector,yVectorRepeat,repeat);

    %% Assign all the data properly depending on doing a back and forth scan.
    updateSR830AveragePlots(plotHandles,avgParam,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,currentAvgIndex,halfway);
    currentAvgIndex = currentAvgIndex + 1;
end
saveData(gcf,genSR830PlotName(sweepType))
end


function updateSR830TimePlots(plotHandles,Real,Imag,Mag,time)
    setPlotXYData(plotHandles{1},time,Real);
    setPlotXYData(plotHandles{2},time,Imag);
    setPlotXYData(plotHandles{3},time,Mag);
end

function setPlotXYData(plotHandle,xDat,yDat)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
end

function updateSR830AveragePlots(plotHandles,avgParam,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,currentIndex,halfway)
    if doBackAndForth && currentIndex > halfway
        setErrorBarXYData(plotHandles{4},avgParam(1:halfway),avgxs(1:halfway),stdx(1:halfway));
        setErrorBarXYData(plotHandles{6},avgParam(1:halfway),avgys(1:halfway),stdy(1:halfway));
        setErrorBarXYData(plotHandles{8},avgParam(1:halfway),avgmags(1:halfway),stdm(1:halfway));

        setErrorBarXYData(plotHandles{5},avgParam(halfway+1:end),avgxs(halfway+1:end),stdx(halfway+1:end));
        setErrorBarXYData(plotHandles{7},avgParam(halfway+1:end),avgys(halfway+1:end),stdy(halfway+1:end));
        setErrorBarXYData(plotHandles{9},avgParam(halfway+1:end),avgmags(halfway+1:end),stdm(halfway+1:end));
    else
        setErrorBarXYData(plotHandles{4},avgParam,avgxs,stdx);
        setErrorBarXYData(plotHandles{5},avgParam,avgys,stdy);
        setErrorBarXYData(plotHandles{6},avgParam,avgmags,stdm);
    end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end

function setGateValue(targetGate,voltageToSet)
    switch targetGate
        case 'STM'
            deviceSet = STMDevice;
            portSet = STMPort;
        case 'TM'
            deviceSet = TMDevice;
            portSet = TMPort;
        case 'Door'
            deviceSet = DoorDevice;
            portSet = DoorPort;
        case 'Res'
            deviceSet = ResDevice;
            portSet = ResPort;
        case 'DP'
            deviceSet = DotDevice;
            portSet = DotPort;
        case 'Pair'
            deviceSet = TMDevice;
            portSet = TMPort;
            deviceSet2 = DotDevice;
            portSet2 = DotPort;
            delta = getVal(DeviceSet2,portSet2) - getVal(deviceSet,portSet);
            voltageToSet2 = voltageToSet + delta;
    end

    setVal(deviceSet,portSet,voltageToSet);
    if strcmp(targetGate,'PR')
        setVal(deviceSet2,portSet2,voltageToSet2);
    end

end


function [x,y,mag,t] = getSR830Data(x,y,mag,t,currentTimeIndex,startTime,waitTime,readSR830)

    x(currentTimeIndex) = currentTimeIndex;%readSR830.queryX();
    y(currentTimeIndex) = currentTimeIndex;%readSR830.queryY();
    t(currentTimeIndex) = (now()-startTime)*86400;
    mag(currentTimeIndex) = sqrt(x(currentTimeIndex)^2 + y(currentTimeIndex)^2);

    pause(waitTime)

end



