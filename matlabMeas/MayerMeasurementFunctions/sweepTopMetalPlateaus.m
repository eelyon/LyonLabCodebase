%% Necessary Constants. Update this from cooldown to cooldown
gain = 35;
capacitance = 4.82*1e-12;

%% Parameters for the shield sweep in the twiddle unload function. It will only take 2 points!
% Change numRepeats to change the number of points taken at each shield voltage.
startShield = 0.1;
stopShield = -0.7;
numRepeats = 25;

TMStepSize = 0.01; % set top metal step size

[sweepNumber,numElectrons] = deal(inf);
[sweepNumFig,sweepNumHandle] = plotData(sweepNumber,numElectrons,'color',"r.",'xLabel',"Sweep Number",'yLabel',"Num Electrons/Channel");

currentNumElectronsPerChannel = 0;
sweepNum = 1;
numConstant = 0;

numInPlateau = 5; % how many times sweep is to be repeated until top metal is changed

cleanTwiddleSense = 1;

while cleanTwiddleSense
    
    TwiddleUnloadSweepTopMetal;
    avgReal = avgReal - avgReal(length(avgReal));
    avgImag = avgImag - avgImag(length(avgImag));
    mag = sqrt(avgReal.^2+avgImag.^2);
    delta = max(mag) - min(mag);
    numEs = (capacitance*2*sqrt(2)*delta)/(1.6e-19*gain);
    
    sweepNumberFig.XData = sweepNum;
    sweepNumberFig.YData = numEs;

    %% Check the previous number of electrons to the current number of electrons.
    % NOISE: abs(currentNumElectronsPerChannel-numEs)<noise/2
    if currentNumElectronsPerChannel == numEs
        % If they are the same, increase the number of constant up by 1
        numConstant = numConstant + 1;
    else
        % If not, update the current number with the new one.
        currentNumElectronsPerChannel = numEs;
    end
    sweepNum = sweepNum + 1;

    %% Check electron number and how many times it has been 1 electron/channel. Kick out of while loop.
    if currentNumElectronsPerChannel == 1 && numConstant == numInPlateau
        cleanTwiddleSense = 0;
        numConstant = 0;
    end

    %% If it's hard to kick electrons out of the channel, ramp the top metal more positive.
    if numConstant == numInPlateau
        numConstant = 0;
        currentTMVoltage = getVal(TM.Device,TM.Port);
        rampVal(TM.Device,TM.Port,currentTMVoltage,currentTMVoltage + TMStepSize,.001,0.1);
        delay(0.1);
    end
    
end

saveData(sweepNumberFig,'numEsVsSweepNum');