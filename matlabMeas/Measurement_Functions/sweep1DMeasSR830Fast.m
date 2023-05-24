function [avgmags] = sweep1DMeasSR830Fast(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth)
% Function sweeps the device and ports from the start to stop parameter
% with a given delta. 
% Parameters:
%           sweepType: cell of character string defining the type of sweep.
%           start: numeric defining the starting value of the swept parameter
%           stop: numeric defining the stoping value of the swept parameter
%           deltaParam: numeric defining the step size of the parameter
%           being swept
%           timeBetweenPoints: the wait time between setting points and
%           collecting data. This should be on the order of the rise time
%           of the lines.
%           repeat: integer number of points to take for averaging. Reduces
%           noise by 1/sqrt(repeat)
%           readSR830: cell array with SR830 objects.
%           device: device object - target device to be swept (DAC,AWG,etc..)
%           ports: cell array defining the ports to be swept. See setval to
%           determine what inputs are acceptable for the object in
%           question.
%           doBackAndForth - 0 (False) or 1 (True). Boolean to determine
%           whether or not to sweep the parameter back to its original
%           value.
for srIndex = 1:length(readSR830)
    [plotHandles{srIndex},subPlotFigureHandles{srIndex}] = initializeSR830Meas1D(sweepType{srIndex},doBackAndForth);
end
%% Parameters to probe

deltaParam = checkDeltaSign(start,stop,deltaParam);

paramVector = start:deltaParam:stop;
if doBackAndForth
    flippedParam = fliplr(paramVector);
    paramVector = [paramVector flippedParam];
end

if strcmp(sweepType{1},'Pair')
    deltaGateParam = getVal(device,ports{2}) - getVal(device,ports{1});
end

numSR830s = length(readSR830);

%% Create all arrays for data storage. 
[Real,Imag,Mag,time,avgParam,avgmags,avgxs,avgys,stdm,stdx,stdy] = deal([]);

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
    tic
    for pIndex = 1:length(ports)
        port = ports{pIndex};
        if pIndex == 1
            setVal(device,port,value);
        else
            setVal(device,port,value+deltaGateParam);
        end
        
    end
    toc
    
    % Update the DAC gui - this is sort of hard coded in maybe I need to
    % make an update function that updates all GUIs present.
    %evalin("base","DACGUI.updateDACGUI");
    drawnow;
    
    delay(timeBetweenPoints);
%     %% Initialize average vectors that gets reset for the repeating for loop
    magVectorRepeat = [];
    xVectorRepeat = [];
    yVectorRepeat = [];
    %% Repeating for loop - changing repeat increases the number of averages to perform per point.

    %% Query SR830 for Real/Imag data, calculate Magnitude and place in vectors
    tic
    [Real,Imag,Mag,time] = getSR830Data(Real,Imag,time,startTime,readSR830,repeat);
    toc
    %% Place data in repeat vectors that get averaged and error bars get calculated.
    for srIndex = 1:numSR830s
        arrLength = length(Mag);
        magVectorRepeat  = Mag(arrLength-repeat+1:arrLength);
        xVectorRepeat   = Real(arrLength-repeat+1:arrLength);
        yVectorRepeat    = Imag(arrLength-repeat+1:arrLength);
    end
    %% Increase timeIndex by 1.
    tic
    currentTimeIndex = currentTimeIndex + 1;
    updateSR830TimePlots(plotHandles,Real,Imag,Mag,time,numSR830s);
    toc
    %% Average all data and place in average arrays.
    magVectorMeans = mean(magVectorRepeat,2);
    xVectorMeans = mean(xVectorRepeat,2);
    yVectorMeans = mean(yVectorRepeat,2);
    for srIndex = 1:numSR830s
        avgParam(srIndex,currentAvgIndex)   = value;
        avgmags(srIndex,currentAvgIndex)    = magVectorMeans(srIndex);
        avgxs(srIndex,currentAvgIndex)      = xVectorMeans(srIndex);
        avgys(srIndex,currentAvgIndex)      = yVectorMeans(srIndex);
    end

    %% Calculate error bars for each point using the repeat vectors.
    for srIndex = 1:numSR830s
        stdm(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,magVectorRepeat(srIndex,:),repeat);
        stdx(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,xVectorRepeat(srIndex,:),repeat);
        stdy(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,yVectorRepeat(srIndex,:),repeat);
    end


    %% Assign all the data properly depending on doing a back and forth scan.
    
    updateSR830AveragePlots(plotHandles,avgParam,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,currentAvgIndex,halfway,numSR830s);
    currentAvgIndex = currentAvgIndex + 1;
    
end

for i = 1:numSR830s
    saveData(subPlotFigureHandles{i},genSR830PlotName(sweepType{i}))
end
end


function updateSR830TimePlots(plotHandles,Real,Imag,Mag,time,numSR830s)
for srIndex = 1:numSR830s
    currentHandleSet = plotHandles{srIndex};
    setPlotXYData(currentHandleSet{1},time,Real);
    setPlotXYData(currentHandleSet{2},time,Imag);
    setPlotXYData(currentHandleSet{3},time,Mag);
    axis tight;
end
    
end

function updateSR830AveragePlots(plotHandles,avgParam,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,currentIndex,halfway,numSR830s)
for srIndex = 1:numSR830s
    currentHandleSet = plotHandles{srIndex};
    if doBackAndForth && currentIndex > halfway
        setErrorBarXYData(currentHandleSet{4},avgParam(srIndex,1:halfway),avgxs(srIndex,1:halfway),stdx(srIndex,1:halfway));
        setErrorBarXYData(currentHandleSet{6},avgParam(srIndex,1:halfway),avgys(srIndex,1:halfway),stdy(srIndex,1:halfway));
        setErrorBarXYData(currentHandleSet{8},avgParam(srIndex,1:halfway),avgmags(srIndex,1:halfway),stdm(srIndex,1:halfway));

        setErrorBarXYData(currentHandleSet{5},avgParam(srIndex,halfway+1:end),avgxs(srIndex,halfway+1:end),stdx(srIndex,halfway+1:end));
        setErrorBarXYData(currentHandleSet{7},avgParam(srIndex,halfway+1:end),avgys(srIndex,halfway+1:end),stdy(srIndex,halfway+1:end));
        setErrorBarXYData(currentHandleSet{9},avgParam(srIndex,halfway+1:end),avgmags(srIndex,halfway+1:end),stdm(srIndex,halfway+1:end));
    elseif doBackAndForth && currentIndex <= halfway
            setErrorBarXYData(currentHandleSet{4},avgParam(srIndex,:),avgxs(srIndex,:),stdx(srIndex,:));
            setErrorBarXYData(currentHandleSet{6},avgParam(srIndex,:),avgys(srIndex,:),stdy(srIndex,:));
            setErrorBarXYData(currentHandleSet{8},avgParam(srIndex,:),avgmags(srIndex,:),stdm(srIndex,:));
    else
        setErrorBarXYData(currentHandleSet{4},avgParam(srIndex,:),avgxs(srIndex,:),stdx(srIndex,:));
        setErrorBarXYData(currentHandleSet{5},avgParam(srIndex,:),avgys(srIndex,:),stdy(srIndex,:));
        setErrorBarXYData(currentHandleSet{6},avgParam(srIndex,:),avgmags(srIndex,:),stdm(srIndex,:));
    end
end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end


function [x,y,mag,t] = getSR830Data(x,y,t,startTime,readSR830,numPointsToRead)
% Function pulls the x,y,magnitude, and time data for each point from the
% targetSR830. IMPORTANT: readSR830 needs to be a cell array of SR830
% objects!!!.
    currentSR830 = readSR830{1};
    x = [x,currentSR830.SR830queryXFast(numPointsToRead)];
    y = [y,currentSR830.SR830queryYFast(numPointsToRead)];
    t = [t,(now() - startTime)*86400 - linspace(0,numPointsToRead/512,numPointsToRead)];
    mag = sqrt(x.^2 + y.^2);
end

function [x,y,mag,t] = getSR830DataCapacitance(x,y,mag,t,currentTimeIndex,startTime,readSR830)
% Function pulls the x,y,magnitude, and time data for each point from the
% targetSR830. IMPORTANT: readSR830 needs to be a cell array of SR830
% objects!!!.
for i = 1:length(readSR830)
    currentSR830 = readSR830{i};
    Igain = 1e12.*-1/(2*pi*SR830queryAmplitude(currentSR830)*SR830queryFreq(currentSR830));
    x(i,currentTimeIndex) = currentSR830.SR830queryX()*Igain;
    y(i,currentTimeIndex) = currentSR830.SR830queryY()*Igain;
    t(i,currentTimeIndex) = (now()-startTime)*86400;
    mag(i,currentTimeIndex) = sqrt(x(currentTimeIndex)^2 + y(currentTimeIndex)^2);
    delay(.005);
end
end



