function [] = sweep1DHP3577A(start,stop,deltaParam,timeBetweenPoints,NetworkAnalyzer,device,startFreq,stopFreq,resistance)
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
%           opt - 0 (Current) or 1 (Voltage) measurement. 

 [plotHandle,subPlotFigureHandle] = initializeHP3577AMeas1D();
%% Parameters to probe

deltaParam = checkDeltaSign(start,stop,deltaParam);

paramVector = start:deltaParam:stop;

%% Create all arrays for data storage. 
[gateV,gain,freq,inducedVoltage,measuredVoltage] = deal([]);
currentIndex = 1;
%% Main parameter loop.
for value = paramVector
        setVal(device,16,value);
        interleavedRamp([device,device],[14,15],[value+1.7,value+1.8],25,0.05);
       
    
    % Update the DAC gui - this is sort of hard coded in maybe I need to
    % make an update function that updates all GUIs present.
%     evalin("base","DACGUI.updateDACGUI");
%     drawnow;
%     
    set3577Average(NetworkAnalyzer,'0');
    delay(1.5);
    set3577Average(NetworkAnalyzer,'128');
    delay(timeBetweenPoints);
    [freqArr,datArr,voltageGain,fit] = pull3577ARollOff(NetworkAnalyzer,startFreq,stopFreq);
    gateV(currentIndex) = value;
    gain(currentIndex) = fit.a+fit.c;
    freq(currentIndex) = abs(fit.b);

    capacitance = 1/(2*pi*abs(fit.b)*resistance);
    inducedVoltage(currentIndex) = 1.6*10^(-19)/(capacitance)*1e9;
    measuredVoltage(currentIndex) = inducedVoltage(currentIndex)*gain(currentIndex);
    setPlotXYData(plotHandle{1},gateV,gain);
    setPlotXYData(plotHandle{2},gateV,freq);
    setPlotXYData(plotHandle{3},gateV,inducedVoltage);
    setPlotXYData(plotHandle{4},gateV,measuredVoltage);
    currentIndex = currentIndex + 1;
    %% Initialize average vectors that gets reset for the repeating for loop
%     magVectorRepeat = [];
%     xVectorRepeat = [];
%     yVectorRepeat = [];
    
    %% Repeating for loop - changing repeat increases the number of averages to perform per point.
%     for j = 1:repeat
%         %% Query SR830 for Real/Imag data, calculate Magnitude and place in vectors
%         if strcmp(sweepType,'IDC')
%             [Real,Imag,Mag,time] = getSR830DataCapacitance(Real,Imag,Mag,time,currentTimeIndex,startTime,HP577A);
%         else
%             [Real,Imag,Mag,time] = getSR830Data(Real,Imag,Mag,time,currentTimeIndex,startTime,HP577A);
%         end
% 
%         %% Place data in repeat vectors that get averaged and error bars get calculated.
%         for srIndex = 1:numSR830s
%             magVectorRepeat(srIndex,j)  = Mag(srIndex,currentTimeIndex);
%             xVectorRepeat(srIndex,j)    = Real(srIndex,currentTimeIndex);
%             yVectorRepeat(srIndex,j)    = Imag(srIndex,currentTimeIndex);
%         end
%         %% Increase timeIndex by 1.
%         currentTimeIndex = currentTimeIndex + 1;
%         
%     end
%     updateSR830TimePlots(plotHandles,Real,Imag,Mag,time,numSR830s);
%     
%     %% Average all data and place in average arrays.
%     magVectorMeans = mean(magVectorRepeat,2);
%     xVectorMeans = mean(xVectorRepeat,2);
%     yVectorMeans = mean(yVectorRepeat,2);
%     for srIndex = 1:numSR830s
%         avgParam(srIndex,currentAvgIndex)   = value;
%         avgmags(srIndex,currentAvgIndex)    = magVectorMeans(srIndex);
%         avgxs(srIndex,currentAvgIndex)      = xVectorMeans(srIndex);
%         avgys(srIndex,currentAvgIndex)      = yVectorMeans(srIndex);
%     end
% 
%     %% Calculate error bars for each point using the repeat vectors.
%     for srIndex = 1:numSR830s
%         stdm(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,magVectorRepeat(srIndex,:),repeat);
%         stdx(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,xVectorRepeat(srIndex,:),repeat);
%         stdy(srIndex,currentAvgIndex)   = calculateErrorBar(errorType,CIVector,yVectorRepeat(srIndex,:),repeat);
%     end


    %% Assign all the data properly depending on doing a back and forth scan.
    
end

end

