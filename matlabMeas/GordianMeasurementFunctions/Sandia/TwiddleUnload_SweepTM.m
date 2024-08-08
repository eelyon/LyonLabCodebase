%% Necessary Constants. Update this from cooldown to cooldown
gain = 34; % Enter gain from roll-off plot
capacitance = 5.35*1e-12; % Enter approximate HEMT input capacitance

%% Parameters for the shield sweep in the twiddle unload function. It will only take 2 points!
% Change numRepeats to change the number of points taken at each shield voltage.
startShield = 0.1;
stopShield = -0.7;
numRepeats = 10;

TMStepSize = 0.05; % Set top metal step size

[sweepNumber,numElectrons,yErrElectrons] = deal(inf); % Set up empty array for storing data
[sweepNumFig,sweepNumHandle] = plotData(sweepNumber,numElectrons,'color',"r.",'xLabel',"Sweep #",'yLabel',"Total # of electrons",'type',"errorbar",'yError',yErrElectrons);

currentNumEs = 0; % Current number of electrons
sweepNum = 1; % Counter for no. of unloading runs
numConstant = 0; % Counter for constant no. of electrons
numInPlateau = 3; % Max. number of constant no. of electrons

cleanTwiddleSense = 1;

while cleanTwiddleSense
    
    TwiddleUnload; % Run twiddle unloading script
    avgReal = avgReal - avgReal(length(avgReal)); % Subtract background from Re
    avgImag = avgImag - avgImag(length(avgImag)); % Subtract background from Imag
    mag = sqrt(avgReal.^2 + avgImag.^2); % Calc. magnitude
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

    %% Check the previous number of electrons to the current number of electrons.
    % NOISE: abs(currentNumEs-numEs)<stdev
    if abs(currentNumEs-numEs) < 2*yErrE
        % If they are the same, increase the number of constant up by 1.
        numConstant = numConstant + 1;
    else
        % If not, update the current number with the new one.
        currentNumEs = numEs;
    end
    sweepNum = sweepNum + 1;

    %% If it's hard to kick electrons out of the channel, ramp the top metal more positive.
    if numConstant == numInPlateau
        numConstant = 0; % Reset numConstant
        currentTMVoltage = getVal(TM.Device,TM.Port);
        interleavedRamp(TM.Device,TM.Port,currentTMVoltage + TMStepSize,2,0.5);
        fprintf(['--> Change top metal voltage to ',num2str(currentTMVoltage+TMStepSize),'V\n']);
        delay(0.5);
%         currentTMvoltage(sweepNum) = currentTMVoltage + TMStepSize;
%         metadata_struct.TMvoltage = [num2str(currentTMVoltage+TMStepSize)];
%         myFig.UserData = metadata_struct;
%         disp(metadata_struct);
    end

    %% Check electron number and how many times it has been 1 electron/channel. Kick out of while loop.
    if currentNumEs > 1-yErrE && currentNumEs < 1+yErrE
        cleanTwiddleSense = 0;
        numConstant = 0;
    end

end

saveData(sweepNumFig,'numEvsSweepNum');

function [nE] = calcNumElectrons(capacitance,Volts,gain)
    nE = (capacitance*2*sqrt(2)*Volts)/(1.602e-19*gain);
end