
%% Voltages to probe
V = startV:deltaV:stopV;

%% Create all local arrays for data storage. To be assigned to workspace variables.
vavgVoltage = [];
avgmags = [];
avgxs = [];
avgys = [];
stdx = [];
stdy = [];
stdm = [];

x = [];
y = [];
magVector = [];
t = [];

%% Halfway point in case back and forth is done.
halfway = length(V)/2;

%% Index for time axis.
currentTimeIndex = 1;

%% 95% confidence interval vector.
CIVector = tinv([0.025 0.975], repeat-1); 

%% Define a cleanup function that will save data on user interrupt.
handle = gcf;
cleanupObj = onCleanup(@()cleanMeUp(handle));

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
        [x,y,magVector,t,v ] = getSR830Data(readSR830,x,y,magVector,t,v,currentTimeIndex,startTime,timeBetweenPoints);
        
        %% Place data in repeat vectors that get averaged and error bars get calculated.
        magVectorRepeat(j) = magVector(currentTimeIndex);
        xVectorRepeat(j) = x(currentTimeIndex);
        yVectorRepeat(j) = y(currentTimeIndex);

        t(currentTimeIndex+1) = t(currentTimeIndex);
        currentTimeIndex = currentTimeIndex + 1;

    end
    
    vavgVoltage = [vavgVoltage Vout];
    avgmags = [avgmags mean(magVectorRepeat)];
    avgxs = [avgxs mean(xVectorRepeat)];
    avgys = [avgys mean(yVectorRepeat)];

    [magError,xError,yError] = calculateSR830ErrorBars(errorType,CIVector,magVectorRepeat,xVectorRepeat,yVectorRepeat,repeat);
    stdm = [stdm magError];
    stdx = [stdx xError];
    stdy = [stdy yError];
   
    assignDataSR830Sweep(t,x,y,vavgVoltage,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,halfway);

end
    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'Sweep');
    end
end

function setGateValue(targetGate,voltageToSet)
    switch targetGate
        case 'STM'
            deviceSet = evalin("base",STMDevice);
            portSet = evalin("base",STMPort);
        case 'TM'
            deviceSet = evalin("base",TMDevice);
            portSet = evalin("base",TMPort);
        case 'Door'
            deviceSet = evalin("base",DoorDevice);
            portSet = evalin("base",DoorPort);
        case 'Res'
            deviceSet = evalin("base",ResDevice);
            portSet = evalin("base",ResPort);
        case 'DP'
            deviceSet = evalin("base",DotDevice);
            portSet = evalin("base",DotPort);
        case 'Pair'
            deviceSet = evalin("base",TMDevice);
            portSet = evalin("base",TMPort);
            deviceSet2 = evalin("base",DotDevice);
            portSet2 = evlin("base",DotPort);
            delta = deviceSet2.sigDACQueryVoltage(portSet2) - deviceSet.sigDACQueryVoltage(portSet);
            voltageToSet2 = voltageToSet + delta;
    end

    setVal(deviceSet,portSet,voltageToSet);
    if strcmp(targetGate,'PR')
        setVal(deviceSet2,portSet2,voltageToSet2);
    end

end


function plotName = genSR830PlotName(targetGate)
    switch targetGate
        case 'STM'
            plotName = "Pinchoff";
        case 'TM'
            plotName = "TopMetalSweep";
        case 'Res'
            plotName = "ReservoirSweep";
        case 'Door'
            plotName = "DoorSweep";
        case 'DP'
            plotName = "DotPotentialSweep";
        case 'Pair'
            plotName = "PairSweep";
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

function [magError,xError,yError] = calculateSR830ErrorBars(errorType,CIVector,magVector,avgxVector,avgyVector,repeat)
    if strcmp(errorType,'CI')
        merr = calculateConfidenceInterval(CIVector,magVector,repeat);
        xerr = calculateConfidenceInterval(CIVector,avgxVector,repeat);
        yerr = calculateConfidenceInterval(CIVector,avgyVector,repeat);

        magError = merr(2);
        xError = xerr(2);
        yError = yerr(2);

    else
        magError = std(magVector);
        xError = std(avgxVector);
        yError = std(avgyVector);
    end
end

function assignDataSR830Sweep(t,x,y,mag,vavgVoltage,avgmags,avgxs,avgys,stdm,stdx,stdy,doBackAndForth,halfway)
    assignin("base","time",t);
    assignin("base","Real",x);
    assignin("base","Imag",y);
    assignin("base","Mag",mag);

    if ~doBackAndForth
        assignin("base","vavg1",vavgVoltage);
        assignin("base","avgxs1",avgxs);
        assignin("base","avgys1",avgys);
        assignin("base","avgmags1",avgmags);

        assignin("base","stdm1",stdm);
        assignin("base","stdx1",stdx);
        assignin("base","stdy1",stdy);
    else
        assignin("base","vavg1",vavgVoltage(1:halfway));
        assignin("base","avgxs1",avgxs(1:halfway));
        assignin("base","avgys1",avgys(1:halfway));
        assignin("base","avgmags1",avgmags(1:halfway));

        assignin("base","vavg1",vavgVoltage(halfway+1:end));
        assignin("base","avgxs1",avgxs(halfway+1:end));
        assignin("base","avgys1",avgys(halfway+1:end));
        assignin("base","avgmags1",avgmags(halfway+1:end));

        assignin("base","stdm1",stdm(1:halfway));
        assignin("base","stdx1",stdx(1:halfway));
        assignin("base","stdy1",stdy(1:halfway));

        assignin("base","stdm2",stdm(halfway+1:end));
        assignin("base","stdx2",stdx(halfway+1:end));
        assignin("base","stdy2",stdy(halfway+1:end));
    end
