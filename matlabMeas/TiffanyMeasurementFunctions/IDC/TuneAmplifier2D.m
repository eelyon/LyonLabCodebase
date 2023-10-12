function [currentMag] = TuneAmplifier2D(device, twiddleDevice, doorDevice,twiddleAmp,frequency,doorAmp,typeSweep)
tic

% initialize Agilents
SR830setSensitivity(device,24)                          % set sensitivity to 0.2V
pause(1)
doorDevice.set33220Amplitude(doorAmp,'VRMS')     
doorDevice.set33220Frequency(frequency);
twiddleDevice.set33220Frequency(frequency);
twiddleDevice.set33220Phase(0);                         % this phase will always be 0
twiddleDevice.set33220Amplitude(twiddleAmp,'VRMS')      % set twiddle amplitude to optimize to
twiddleDevice.set33220Output(1);                        % make sure both Agilents are set to output 
doorDevice.set33220Output(1);

if strcmp(typeSweep,'Phase')
    %% Find best phase
    start = -180;
    stop = 360;
    stepSize = [10 1 0.05];
    phases = sweepOptimize(device, doorDevice, stepSize, start, stop, 'Phase');
    adjustSensitivity(device,phases(end))  
    doorDevice.set33220Phase(phases(end));
    currentMag = sqrt(SR830queryX(device)^2 + SR830queryY(device)^2);
else
    %% then find best amplitude at this phase
    SR830setSensitivity(device,24)               % set sensitivity to 0.2V
    start = 0.01;
    stop = 0.1;
    stepSize_amps = [0.01 0.001 0.0001];         % note:lowest rms voltage is 7.1mVrms
    amplitudes = sweepOptimize(device, doorDevice, stepSize_amps, start, stop, 'Amp');
end

    function [phases] = sweepOptimize(device, doorDevice, stepSize, start, stop, type)
        N = 1:length(stepSize);
        phases = zeros(1,numel(N));
        for i = N       
            delta = stepSize(i);
            
            if strcmp(type,'Phase')
                doorDevice.set33220Phase(start)
                pause(0.5)
                mags = sweep1DMeasSR830({'PHAS'},start,stop,delta,0.1,5,{device},doorDevice,{3},0);
                if i > 2
                    adjustSensitivity(device,mags)
                end
            else
                mags = sweep1DMeasSR830({'Vrms'},start,stop,delta,0.1,5,{device},doorDevice,{4},0);
                adjustSensitivity(device,mags)
            end

            xlist = start:delta:stop;
            minimumValue = xlist(find(mags==min(mags)));
            if minimumValue > 350 || minimumValue < -350
                nextMin = min(setdiff(mags,min(mags)));
                minimumValue = xlist(find(mags==nextMin));
            else
            end
            start = minimumValue(1) - stepSize(i);
            stop = minimumValue(1) + stepSize(i);
            phases(i) = minimumValue(1);
        end
    end
    
    function [] = adjustSensitivity(device,mags)
        sensArr = [2e-9, 5e-9, 1e-8, 2e-8, 5e-8, 1e-7, 2e-7,5e-7, 1e-6,2e-6,5e-6,1e-5,2e-5, 5e-5,1e-4,2e-4,5e-4,1e-3,2e-3,5e-3,.01,.02,.05,.1,.2,.5,1];
        incSens = interp1(sensArr,sensArr,mags(1),'nearest');
        setSens = find(sensArr==incSens);
        SR830setSensitivity(device,setSens+1);
    end
toc
end