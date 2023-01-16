initializeSR830Meas1D;
%% Voltages to probe
if startV > stopV && deltaV > 0
    deltaV = -1*deltaV;
elseif startV < stopV && deltaV < 0
    deltaV = -1*deltaV;
end

V = startV:deltaV:stopV;

%% SR830 to read. Note that the name must exist in the base workspace!
readSR830 = evalin("base",SR830ReadName);

%% Create all arrays for data storage. 
[vAvgVoltage,avgmags,avgxs,avgys,stdm,stx,sty] = double.deal(empty(0,0));

%% Halfway point in case back and forth is done.
halfway = length(V)/2;

%% Index for time axis.
currentTimeIndex = 1;
currentAvgIndex = 1;
%% 95% confidence interval vector.
CIVector = tinv([0.025 0.975], repeat-1); 

%% Define a cleanup function that will save data on user interrupt.
handle = gcf;

startTime = now();
%% Main parameter loop.
for Vout = V
    setGateValue(targetGate,Vout);

    DACGUI.updateDACGUI;
    drawnow;
    
    %% Initialize average vectors that gets reset for the repeating for loop
    magVectorRepeat = [];
    xVectorRepeat = [];
    yVectorRepeat = [];
    
    %% Repeating for loop - changing repeat increases the number of averages to perform per point.
    for j = 1:repeat
        
        %% Query SR830 for Real/Imag data, calculate Magnitude and place in vectors
        [Real,Imag,Mag,time,voltage] = getSR830Data(readSR830,Real,Imag,Mag,time,voltage,currentTimeIndex,startTime,timeBetweenPoints);
        
        %% Place data in repeat vectors that get averaged and error bars get calculated.
        magVectorRepeat(j) = Mag(currentTimeIndex);
        xVectorRepeat(j) = Real(currentTimeIndex);
        yVectorRepeat(j) = Imag(currentTimeIndex);

        %% Place time data in time array.
        time(currentTimeIndex+1) = time(currentTimeIndex);
        currentTimeIndex = currentTimeIndex + 1;

    end

    %% Average all data and place in average arrays.
    vavgVoltage(currentAvgIndex)    = Vout;
    avgmags(currentAvgIndex)        = mean(magVectorRepeat);
    avgxs(currentAvgIndex)          = mean(xVectorRepeat);
    avgys(currentAvgIndex)          = mean(yVectorRepeat);
    
    %% Calculate error bars for each point using the repeat vectors.
    magError    = calculateSR830ErrorBar(errorType,CIVector,magVectorRepeat,repeat);
    xError      = calculateSR830ErrorBar(errorType,CIVector,xVectorRepeat,repeat);
    yError      = calculateSR830ErrorBar(errorType,CIVector,yVectorRepeat,repeat);
    stdm(currentAvgIndex) = magError;
    stdx(currentAvgIndex) = xError;
    stdy(currentAvgIndex) = yError;
    
    %% Assign all the data properly depending on doing a back and forth scan.
    assignDataSR830Sweep(vavgVoltage,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,currentAvgIndexhalfway);
    currentAvgIndex = currentAvgIndex + 1;
end

saveData(gcf,genSR830PlotName(sweepType))

function assignDataSR830Sweep(vAvgVoltage,avgMagArr,avgXs,avgYs,stdm,stdx,stdy,doBackAndForth,currentIndex,halfway)
    if doBackAndForth && currentIndex > halfway
        assignin("base","vavg1",vAvgVoltage(1:halfway));
        assignin("base","avgmags1",avgMagArr(1:halfway));
        assignin("base","avgxs1",avgXs(1:halfway));
        assignin("base","avgys1",avgYs(1:halfway));
        assignin("base","stdm1",stdm(1:halfway));
        assignin("base","stdx1",stdx(1:halfway));
        assignin("base","stdy1",stdy(1:halfway));

        assignin("base","vavg2",vAvgVoltage(halfway+1:end));
        assignin("base","avgmags2",avgMagArr(halfway+1:end));
        assignin("base","avgxs2",avgXs(halfway+1:end));
        assignin("base","avgys2",avgYs(halfway+1:end));
        assignin("base","stdm2",stdm(halfway+1:end));
        assignin("base","stdx2",stdx(halfway+1:end));
        assignin("base","stdy2",stdy(halfway+1:end));
    else
        assignin("base","vavg1",vAvgVoltage);
        assignin("base","avgmags1",avgMagArr);
        assignin("base","avgxs1",avgXs);
        assignin("base","avgys1",avgYs);
        assignin("base","stdm1",stdm);
        assignin("base","stdx1",stdx);
        assignin("base","stdy1",stdy);
    end
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


function [x,y,mag,t,v] = getSR830Data(readSR830,x,y,mag,t,v,currentTimeIndex,startTime,waitTime)

    x(currentIndex) = readSR830.queryX();
    y(currentIndex) = readSR830.queryY();
    v(currentIndex) = Vout;
    t(currentIndex) = (now()-startTime)*86400;
    mag(currentIndex) = sqrt(x(currentTimeIndex)^2 + y(currentTimeIndex)^2);

    pause(waitTime)

end


function CIErr = calculateConfidenceInterval(CIVector,arr,numRepeats)
    CIErr = (std(arr)/sqrt(numRepeats).*CIVector)*2;
end

function [err] = calculateSR830ErrorBar(errorType,CIVector,vector,repeat)
    if strcmp(errorType,'CI')
        verr = calculateConfidenceInterval(CIVector,vector,repeat);
        err = verr(2);
    else
        err = std(vector);
    end
end
