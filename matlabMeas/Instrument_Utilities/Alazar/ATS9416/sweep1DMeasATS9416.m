function [mag,phase,x,y,stdm,stdphase,stdx,stdy] = sweep1DMeasATS9416(sweepType,start,stop,deltaParam,timeBetweenPoints,postTriggerSamples,boardHandle,channelMask,device,port,doBackAndForth)
%sweep1DMeasATS9416 Summary of this function goes here
%   Detailed explanation goes here

[plotHandles,subPlotFigureHandles] = initializeATS9416Meas1D(sweepType,doBackAndForth);

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
    f_signal = 1e6;
    
    % NPT parameters
%     postTriggerSamples = 1000064; % Has to be at least 256 and multiple of 128
    recordsPerBuffer = 1; % Set for averaging
    buffersPerAcquisition = 1; % Set number of buffers
    
    % Lock-in parameters
    stages = 4; % RC filter stages
    fc = 1; % RC filter cut off frequency
    phaseOffset = 179.746; % Phase adjustment

    global samplesPerSec
    
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

function updateATS9416Plots(plotHandles,xvolts,mag,phase,x,y,stdm,stdphase,stdx,stdy,doBackAndForth,index,halfway)
currentHandleSet = plotHandles{1};
if doBackAndForth && index > halfway
    setErrorBarXYData(currentHandleSet{4},xvolts(1:halfway),x(1:halfway),stdx(1:halfway));
    setErrorBarXYData(currentHandleSet{6},xvolts(1:halfway),y(1:halfway),stdy(1:halfway));

    setErrorBarXYData(currentHandleSet{5},xvolts(halfway+1:end),mag(halfway+1:end),stdm(halfway+1:end));
    setErrorBarXYData(currentHandleSet{7},xvolts(halfway+1:end),phase(halfway+1:end),stdphase(halfway+1:end));
elseif doBackAndForth && index <= halfway
        setErrorBarXYData(currentHandleSet{4},xvolts,x,stdx);
        setErrorBarXYData(currentHandleSet{6},xvolts,y,stdy);
else
    setErrorBarXYData(currentHandleSet{4},xvolts,x,stdx);
    setErrorBarXYData(currentHandleSet{5},xvolts,y,stdy);
    setErrorBarXYData(currentHandleSet{6},xvolts,mag,stdm);
end
end

function setErrorBarXYData(plotHandle,xDat,yDat,yErr)
    plotHandle.XData = xDat;
    plotHandle.YData = yDat;
    plotHandle.YPositiveDelta = yErr;
    plotHandle.YNegativeDelta = yErr;
end

end

