function [mag,phase,x,y,stdm,stdphase,stdx,stdy] = sweep1DMeasATS9416(sweepType,start,stop,deltaParam,timeBetweenPoints,boardHandle,channelMask,device,port,doBackAndForth)
%sweep1DMeasATS9416 Summary of this function goes here
%   Detailed explanation goes here
[plotHandles{1},subPlotFigureHandles] = initializeATS9416Meas1D(sweepType{1},doBackAndForth);

% Adjust for sign of sweep
deltaParam = checkDeltaSign(start,stop,deltaParam);
paramVector = start:deltaParam:stop;

if doBackAndForth
    flippedParam = fliplr(paramVector);
    paramVector = [paramVector flippedParam];
end

%% Create all arrays for data storage. 
[xvolts,mag,phase,x,y,stdm,stdphase,stdx,stdy] = deal([]);

%% Halfway point in case back and forth is done.
halfway = length(paramVector)/2;
index = 1;

%% Main parameter loop
for value = paramVector

    setVal(device,port,value);
    delay(timeBetweenPoints);

    % Set parameters for acquisition
    global samplesPerSec
    f_signal = 1e6;
    
    % NPT parameters
    postTriggerSamples = 1000064; % Has to be at least 256 and multiple of 128
    recordsPerBuffer = 1; % Set for averaging
    buffersPerAcquisition = 1; % Set number of buffers
    
    % Lock-in parameters
    stages = 4; % RC filter stages
    fc = 1; % RC filter cut off frequency
    phaseOffset = 179.7; % Phase adjustment

    %% Query ATS9416 for data, calculate X and Y, average, and place in vectors
    [~,bufferVolts] = ATS9416AcquireData_NPT(boardHandle,postTriggerSamples,recordsPerBuffer,buffersPerAcquisition,channelMask);
    [Xrms,Yrms,stdXrms,stdYrms] = ATS9416GetXY(bufferVolts,samplesPerSec,postTriggerSamples,f_signal,phaseOffset*pi/180,stages,fc,1);

    x(index) = Xrms;
    y(index) = Yrms;
    stdx(index) = stdXrms;
    stdy(index) = stdYrms;
    
    Rrms = sqrt(Xrms.^2+Yrms.^2); % Magnitude in rms
    phi = rad2deg(atan2(real(Yrms),real(Xrms))); % Phase in degrees
    stdRrms = sqrt(stdXrms.^2+stdYrms.^2); % Magnitude error in rms
    stdPhi = sqrt(1/(Xrms.^2+Yrms.^2).^2*(Yrms.^2*stdXrms.^2+Xrms.^2*stdYrms.^2)); % Phase error in degrees

    xvolts(index) = value;
    mag(index) = Rrms;
    phase(index) = phi;
    stdm(index) = stdRrms;
    stdphase(index) = stdPhi;

    %% Assign all the data properly depending on doing a back and forth scan
    updateATS9416Plots(plotHandles,xvolts,mag,phase,x,y,stdm,stdphase,stdx,stdy,doBackAndForth,index,halfway);
    index = index + 1;
end

%% Save data
saveData(subPlotFigureHandles,genSR830PlotName(sweepType{1}));

%% Function for updating plot and setting errorbars
function updateATS9416Plots(plotHandles,xvolts,mag,phase,x,y,stdm,stdphase,stdx,stdy,doBackAndForth,index,halfway)
currentHandleSet = plotHandles{1};
if doBackAndForth && index <= halfway
    setErrorBarXYData(currentHandleSet{1},xvolts,x,stdx);
    setErrorBarXYData(currentHandleSet{3},xvolts,y,stdy);
    setErrorBarXYData(currentHandleSet{5},xvolts,mag,stdm);
    setErrorBarXYData(currentHandleSet{7},xvolts,phase,stdphase);
elseif doBackAndForth && index > halfway
    setErrorBarXYData(currentHandleSet{1},xvolts(1:halfway),x(1:halfway),stdx(1:halfway));
    setErrorBarXYData(currentHandleSet{3},xvolts(1:halfway),y(1:halfway),stdy(1:halfway));
    setErrorBarXYData(currentHandleSet{5},xvolts(1:halfway),mag(1:halfway),stdm(1:halfway));
    setErrorBarXYData(currentHandleSet{7},xvolts(1:halfway),phase(1:halfway),stdphase(1:halfway));

    setErrorBarXYData(currentHandleSet{2},xvolts(halfway+1:end),x(halfway+1:end),stdx(halfway+1:end));
    setErrorBarXYData(currentHandleSet{4},xvolts(halfway+1:end),y(halfway+1:end),stdy(halfway+1:end));
    setErrorBarXYData(currentHandleSet{6},xvolts(halfway+1:end),mag(halfway+1:end),stdm(halfway+1:end));
    setErrorBarXYData(currentHandleSet{8},xvolts(halfway+1:end),phase(halfway+1:end),stdphase(halfway+1:end));
else
    setErrorBarXYData(currentHandleSet{1},xvolts,x,stdx);
    setErrorBarXYData(currentHandleSet{2},xvolts,y,stdy);
    setErrorBarXYData(currentHandleSet{3},xvolts,mag,stdm);
    setErrorBarXYData(currentHandleSet{4},xvolts,phase,stdphase);
end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end
end