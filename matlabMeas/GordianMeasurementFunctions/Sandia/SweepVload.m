%% Script for measuring electrons in 1st twiddle-sense as function of different loading voltages
%% Necessary Constants. Update this from cooldown to cooldown
gain = 25.2; % Enter gain from roll-off plot
capacitance = 4.85*1e-12; % Enter approximate HEMT input capacitance

%% Parameters for the shield sweep in the twiddle unload function. It will only take 2 points!
sweepNum = 1; % counter for no. of unloading runs
currentNumEs = 0; % current number of electrons

%% Set up plot and arrays for data storage
[Vloads,numElectrons,yErrElectrons] = deal(inf); % set up empty array for storing data
[VloadsFig,VloadsHandle] = plotData(Vloads,numElectrons,'color',"r.",'xLabel',"V_{load} (V)",'yLabel',"Total # of electrons",'type',"errorbar",'yError',yErrElectrons);

startShield = 0;
stopShield = -2;

startVload = -0.1;
stopVload = 0.3;
VloadStep = 0.05; % set Vload step size
array = startVload:VloadStep:stopVload;

% numRepeats = 10; % points averaged over for each sweep point

TwiddleUnload_Full;

for n = 1:length(array)
    Vload = array(n);
    TwiddleLoad; % Run twiddle unloading script
    shieldVals = 0.15:-0.05:-0.15;
    startShield = shieldVals(find(avg_real==min(avg_real))); % Update startShield
    
    [avgMag,avgReal,avgImag,stdReal,stdImag] = sweep1DMeasSR830({'Load'},startShield,stopShield,stopShield-startShield,10,10,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1);
    interleavedRamp(guard1_l.Device,guard1_l.Port,startShield,numStepsRC,waitTime) % open shield

    mag = correctedMag(avgReal,avgImag); % Get corrected magnitude
    delta = max(mag) - min(mag); % Calc. change in signal
    numEs = calcNumElectrons(capacitance,delta,gain); % Calc. tot. no. of electrons
    fprintf(['-> For Vload = ',num2str(Vload),'V, numEs = ',num2str(numEs),'\n'])

    stdm = sqrt(stdReal.^2 + stdImag.^2); % Calc. standard deviation of magnitude
    deltaErr = stdm(1)+stdm(2);
    yErrE = calcNumElectrons(capacitance,deltaErr,gain); % Calc. standard deviation for electron no.
    
    Vloads(sweepNum) = Vload;
    numElectrons(sweepNum) = numEs;
    yErrElectrons(sweepNum) = yErrE;
    
    VloadsFig.XData = Vloads;
    VloadsFig.YData = numElectrons;
    VloadsFig.YPositiveDelta = yErrElectrons;
    VloadsFig.YNegativeDelta = yErrElectrons;
    
    refreshdata;
    drawnow;
    
    %% Do full shield gate sweep every 5 sweeps or when there are 6 electrons less than before
%     if sweepNum == 1 || mod(sweepNum,5) == 0 || abs(currentNumEs-numEs) > 6 
%         [avg_mag,avg_real,avg_imag,std_real,std_imag] = sweep1DMeasSR830Fast({'Shield'},0.2,-0.1,0.05,10,numRepeats,{SR830Twiddle},guard1_l.Device,{guard1_l.Port},0,1);
%         shieldVals = 0.2:-0.05:-0.1;
%         startShield = shieldVals(find(avg_real==min(avg_real))); % Update startShield
%     end

    sweepNum = sweepNum + 1; % update sweepNum counter
    currentNumEs = numEs; % update currentNumEs
    cleanTwiddleSense = 1;

    %% Clean twiddle-sense until empty
    while cleanTwiddleSense

        TwiddleUnload_Full; % unload all electrons from twiddle-sense
        mag = correctedMag(avg_Real,avg_Imag); % Get corrected magnitude
        delta = max(mag) - min(mag); % Calc. change in signal
        numEs = calcNumElectrons(capacitance,delta,gain); % Calc. tot. no. of electrons
        
        if numEs < 1
            cleanTwiddleSense = 0;
            fprintf('Twiddle-sense emptied\n')
        end
    end
end

saveData(VloadsFig,'numEvsVload');

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