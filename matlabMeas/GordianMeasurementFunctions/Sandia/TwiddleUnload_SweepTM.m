%% Necessary Constants. Update this from cooldown to cooldown
gain = 28.3; % Enter gain from roll-off plot
capacitance = 5.11*1e-12; % Enter approximate HEMT input capacitance

%% Parameters for the shield sweep in the twiddle unload function. It will only take 2 points!
TMStepSize = 0.2; % Set top metal step size
currentNumEs = 0; % Current number of electrons
sweepNum = 1; % Counter for no. of unloading runs
numConstant = 0; % Counter for constant no. of electrons
numInPlateau = 3; % Max. number of constant no. of electrons
cleanTwiddleSense = 1; % Condition for exiting while loop

%% Set up plot and arrays for data storage
[sweepNumber,numElectrons,yErrElectrons] = deal(inf); % Set up empty array for storing data
[sweepNumFig,sweepNumHandle] = plotData(sweepNumber,numElectrons,'color',"r.",'xLabel',"Sweep #",'yLabel',"Total # of electrons",'type',"errorbar",'yError',yErrElectrons);

%% Run an initial shield sweep and determine startShield
[avg_mag,avg_real,avg_imag,std_real,std_imag] = sweep1DMeasSR830({'Shield'},0.14,0,0.02,10,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1);
corrMag = correctedMag(avg_real,avg_imag); % Get corrected magnitude
shieldVals = 0.14:-0.02:0; % Set array of shield sweep values
startShield = shieldVals(find(corrMag==max(corrMag)));
stopShield = -2;
numRepeats = 20; % Points averaged over for each sweep point

while cleanTwiddleSense
    
    TwiddleUnload; % Run twiddle unloading script
    mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
    delta = max(mag) - min(mag); % Calc. change in signal
    numEs = calcNumElectrons(capacitance,delta,gain); % Calc. tot. no. of electrons

    stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
    deltaErr = stdm(find(mag==max(mag)))+stdm(find(mag==min(mag)));
    yErrE = calcNumElectrons(capacitance,deltaErr,gain); % Calc. standard deviation for electron no.
    
    sweepNumber(sweepNum) = sweepNum;
    numElectrons(sweepNum) = numEs;
    yErrElectrons(sweepNum) = yErrE;

    sweepNumFig.XData = sweepNumber;
    sweepNumFig.YData = numElectrons;
    sweepNumFig.YPositiveDelta = yErrElectrons;
    sweepNumFig.YNegativeDelta = yErrElectrons;

    refreshdata;
    drawnow;

    %% Do full shield gate sweep every 10 sweeps or when there are 10 less electrons than before
    if mod(sweepNum,10) == 0 || (abs(currentNumEs-numEs) > 6 && sweepNum > 1)
        [avg_mag,avg_real,avg_imag,std_real,std_imag] = sweep1DMeasSR830({'Shield'},0.14,0,0.02,10,10,{SR830Twiddle},shieldl.Device,{shieldl.Port},0,1);
        shieldVals = 0.14:-0.02:0;
        startShield = shieldVals(find(avg_real==min(avg_real))); % Update startShield
    end
    sweepNum = sweepNum + 1; % Update sweepNum counter

    %% Check the previous number of electrons to the current number of electrons.
    if abs(currentNumEs-numEs) < 1.3 % Error is based on the number of electrons that can be resolved % 4*yErrE
        % If they are the same, increase the number of constant up by 1.
        numConstant = numConstant + 1; % Update numConstant counter
    else
        % If not, update the current number with the new one.
        currentNumEs = numEs;
    end

    %% If it's hard to kick electrons out of the channel, ramp the top metal more positive.
    if numConstant == numInPlateau
        numConstant = 0; % Reset numConstant
        currentTMVoltage = getVal(TM.Device,TM.Port);
        interleavedRamp(TM.Device,TM.Port,currentTMVoltage + TMStepSize,2,0.5);
        fprintf(['-> Change top metal voltage to ',num2str(currentTMVoltage+TMStepSize),'V\n']);
        delay(0.5);
    end

    %% Check electron number and how many times it has been 1 electron/channel. Kick out of while loop.
    if currentNumEs > (1-yErrE) && currentNumEs < (1+yErrE) && numConstant == numInPlateau
        cleanTwiddleSense = 0;
        numConstant = 0;
    end

end

saveData(sweepNumFig,'numEvsSweepNum');

function [nE] = calcNumElectrons(capacitance,Volts,gain)
% Calc. electron number from measured voltage
    nE = (capacitance*2*sqrt(2)*Volts)/(1.602e-19*gain);
end

function [corrMag] = correctedMag(real,imag)
% Correct measured magnitude by background signal
    corrReal = real - real(length(real)); % Subtract background from Re
    corrImag = imag - imag(length(imag)); % Subtract background from Imag
    corrMag = sqrt(corrReal.^2 + corrImag.^2); % Calc. magnitude
end