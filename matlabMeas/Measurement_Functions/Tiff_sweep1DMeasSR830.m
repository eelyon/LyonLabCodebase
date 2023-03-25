function [ ] = Tiff_sweep1DMeasSR830(sweepType,start,stop,deltaParam,timeBetweenPoints,repeat,readSR830,device,ports,doBackAndForth)
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

[plotHandles,subPlotFigureHandles] = Tiff_initializeSR830Meas1D(sweepType,doBackAndForth);
deltaParam = checkDeltaSign(start,stop,deltaParam);
paramVector = start:deltaParam:stop;

if doBackAndForth
    flippedParam = fliplr(paramVector);
    paramVector = [paramVector flippedParam];
end

numSR830s = length(readSR830);

%% Create all arrays for data storage. 
[Real,Imag,Mag,RealC,ImagC,MagC,RealE,ImagE,MagE,time,avgParamC,avgmagsC,avgxsC,avgysC,stdxC,stdyC,avgParamE,avgmagsE,avgxsE,avgysE,stdxE,stdyE] = deal([]);

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
for valueE = paramVector
    
    if length(ports) > 1
        setVal(device,ports{2},valueE);
        valueC = sigDACQueryVoltage(device,ports{1});
        setVal(device,ports{1},valueC+valueE);
    else
        setVal(device,ports{1},valueE);
    end
    
    % Update the DAC gui - this is sort of hard coded in maybe I need to
    % make an update function that updates all GUIs present.
    evalin("base","DACGUI.updateDACGUI");
    drawnow;
    
    pause(timeBetweenPoints);
    %% Initialize average vectors that gets reset for the repeating for loop
    magVectorRepeat = [];
    xVectorRepeat = [];
    yVectorRepeat = [];
    
    %% Repeating for loop - changing repeat increases the number of averages to perform per point.
    for j = 1:repeat
        
        %% Query SR830 for Real/Imag data, calculate Magnitude and place in vectors
        [RealC,ImagC,MagC,time] = getSR830Data(RealC,ImagC,MagC,time,currentTimeIndex,startTime,readSR830{1});
        [RealE,ImagE,MagE,time] = getSR830Data(RealE,ImagE,MagE,time,currentTimeIndex,startTime,readSR830{2});

        %% Place data in repeat vectors that get averaged and error bars get calculated.
        magVectorRepeat(1,j)  = MagC(1,currentTimeIndex);
        xVectorRepeat(1,j)    = RealC(1,currentTimeIndex);
        yVectorRepeat(1,j)    = ImagC(1,currentTimeIndex);
        magVectorRepeat(2,j)  = MagE(1,currentTimeIndex);
        xVectorRepeat(2,j)    = RealE(1,currentTimeIndex);
        yVectorRepeat(2,j)    = ImagE(1,currentTimeIndex);   

        %% Increase timeIndex by 1.
        currentTimeIndex = currentTimeIndex + 1;
        
    
    updateSR830TimePlots(plotHandles,RealC,ImagC,RealE,ImagE,time);
    
    %% Average all data and place in average arrays.
    magVectorMeans = mean(magVectorRepeat,2);
    xVectorMeans = mean(xVectorRepeat,2);
    yVectorMeans = mean(yVectorRepeat,2);
    for srIndex = 1:numSR830s
        if srIndex == 1
            avgParamC(srIndex,currentAvgIndex)   = valueC+valueE;
            avgmagsC(srIndex,currentAvgIndex)    = magVectorMeans(srIndex);
            avgxsC(srIndex,currentAvgIndex)      = xVectorMeans(srIndex);
            avgysC(srIndex,currentAvgIndex)      = yVectorMeans(srIndex);
        else
            avgParamE(1,currentAvgIndex)   = valueE;
            avgmagsE(1,currentAvgIndex)    = magVectorMeans(srIndex);
            avgxsE(1,currentAvgIndex)      = xVectorMeans(srIndex);
            avgysE(1,currentAvgIndex)      = yVectorMeans(srIndex);
        end
    end

    %% Calculate error bars for each point using the repeat vectors.
    for srIndex = 1:numSR830s
        if srIndex == 1
            stdmC(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,magVectorRepeat(srIndex,:),repeat);
            stdxC(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,xVectorRepeat(srIndex,:),repeat);
            stdyC(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,yVectorRepeat(srIndex,:),repeat);
        else
            stdmE(1,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,magVectorRepeat(srIndex,:),repeat);
            stdxE(1,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,xVectorRepeat(srIndex,:),repeat);
            stdyE(1,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,yVectorRepeat(srIndex,:),repeat);
        end
    end

    %% Assign all the data properly depending on doing a back and forth scan.
    updateSR830AveragePlots(plotHandles,avgParamC,avgysC,stdyC,avgParamE,avgysE,stdyE,doBackAndForth,currentAvgIndex,halfway,numSR830s);
    currentAvgIndex = currentAvgIndex + 1;
end

saveData(subPlotFigureHandles,genSR830PlotName(sweepType))

end


function updateSR830TimePlots(plotHandles,RealC,ImagC,RealE,ImagE,time)
srIndex=1;
currentHandleSet = plotHandles;
setPlotXYData(currentHandleSet{1},time,RealC);
setPlotXYData(currentHandleSet{2},time,ImagC);
setPlotXYData(currentHandleSet{4},time,RealE);
setPlotXYData(currentHandleSet{5},time,ImagE);
axis tight;
end

function updateSR830AveragePlots(plotHandles,avgParamC,avgysC,stdyC,avgParamE,avgysE,stdyE,doBackAndForth,currentIndex,halfway,numSR830s)
currentHandleSet = plotHandles;
for srIndex = 1:numSR830s
    if srIndex ==1
        if doBackAndForth && currentIndex > halfway
            setErrorBarXYData(currentHandleSet{5},avgParamC(srIndex,1:halfway),avgysC(srIndex,1:halfway),stdyC(srIndex,1:halfway));
            setErrorBarXYData(currentHandleSet{6},avgParamC(srIndex,halfway+1:end),avgysC(srIndex,halfway+1:end),stdyC(srIndex,halfway+1:end));
        elseif doBackAndForth && currentIndex <= halfway
            setErrorBarXYData(currentHandleSet{5},avgParamC(srIndex,:),avgysC(srIndex,:),stdyC(srIndex,:));
        else
            setErrorBarXYData(currentHandleSet{5},avgParamC(srIndex,:),avgysC(srIndex,:),stdyC(srIndex,:));
        end
    else
        srIndex = 1;
        if doBackAndForth && currentIndex > halfway
            setErrorBarXYData(currentHandleSet{7},avgParamE(srIndex,1:halfway),avgxyE(srIndex,1:halfway),stdyE(srIndex,1:halfway));
            setErrorBarXYData(currentHandleSet{8},avgParamE(srIndex,halfway+1:end),avgysE(srIndex,halfway+1:end),stdyE(srIndex,halfway+1:end));
        elseif doBackAndForth && currentIndex <= halfway
            setErrorBarXYData(currentHandleSet{7},avgParamE(srIndex,:),avgysE(srIndex,:),stdyE(srIndex,:));
        else
            setErrorBarXYData(currentHandleSet{7},avgParamE(srIndex,:),avgysE(srIndex,:),stdyE(srIndex,:));
        end
    end
end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end


function [x,y,mag,t] = getSR830Data(x,y,mag,t,currentTimeIndex,startTime,readSR830)
% Function pulls the x,y,magnitude, and time data for each point from the
% targetSR830. IMPORTANT: readSR830 needs to be a cell array of SR830
% objects!!!.
    i = 1;
    currentSR830 = readSR830;
    x(i,currentTimeIndex) = currentSR830.SR830queryX();
    y(i,currentTimeIndex) = currentSR830.SR830queryY();
    t(i,currentTimeIndex) = (now()-startTime)*86400;
    mag(i,currentTimeIndex) = sqrt(x(currentTimeIndex)^2 + y(currentTimeIndex)^2);
    pause(.005);
end

end



