function [subPlotFigure,tag,myFig] = E5071FreqSweep(ENA,powerIndBm,startFreq,stopFreq,tag,opt)
% E5071FreqSweep  Single sweep on a Keysight E5071 ENA: configure, trigger,
% read log-magnitude and phase, optionally plot, and ALWAYS save raw data.
%
%   ENA        : instrument object (VISA/GPIB, opened with fopen)
%   powerIndBm : source power                     [dBm]
%   startFreq  : start frequency                  [MHz]
%   stopFreq   : stop frequency                   [MHz]
%   tag        : base name for the saved files
%   opt        : (optional) if supplied, plotting is skipped; data is still saved

    % Pre-assign outputs so the call never fails with
    % "Output argument 'subPlotFigure' (and possibly others) not assigned"
    subPlotFigure = [];
    myFig         = [];

    %% Instrument configuration
    E5071SetPower(ENA,powerIndBm);      % [dBm]
    E5071SetStartFreq(ENA,startFreq);   % [MHz]
    E5071SetStopFreq(ENA,stopFreq);     % [MHz]

    %% Match the I/O timeout to the actual sweep duration
    % *OPC? only answers once the sweep is finished. If the sweep lasts longer
    % than ENA.Timeout (visadev default: 10 s), the read times out.
    numPoints = str2double(query(ENA,':SENS1:SWE:POIN?'));   % number of points N
    sweepTime = str2double(query(ENA,':SENS1:SWE:TIME?'));   % single-sweep time [s]
    
    % With sweep averaging, one trigger runs AVER:COUN sweeps
    avgOn   = str2double(query(ENA,':SENS1:AVER?'));
    trigAvg = str2double(query(ENA,':TRIG:AVER?'));
    if avgOn == 1 && trigAvg == 1
        sweepTime = sweepTime * str2double(query(ENA,':SENS1:AVER:COUN?'));
    end
    
    oldTimeout  = ENA.Timeout;                             % [s]
    ENA.Timeout = max(oldTimeout, 1.5*sweepTime + 10);     % margin: overhead + data transfer
    fprintf('Sweep: %d points, est. %.1f s -> timeout %.1f s\n', ...
            numPoints, sweepTime, ENA.Timeout);

    fprintf(ENA,':INIT1');              % continuous: ':INIT1:CONT ON'
    fprintf(ENA,':TRIG:SOUR BUS');      % bus trigger
    fprintf(ENA,':TRIG:SING');          % start one sweep
    query(ENA,'*OPC?');                 % block until sweep complete

    %% Data acquisition
    [fdata,mag,phase] = E5071GetData(ENA,tag);   % f, |S| [dB], angle(S) [deg]

    % Measurement parameter (S11/S21/S12/S22); strip CR/LF and any quotes
    measType = erase(strtrim(query(ENA,':CALC:PAR:DEF?')),'"');

    %% Metadata
    metadata_struct.powerIndBm    = powerIndBm;
    metadata_struct.startFreq_MHz = startFreq;
    metadata_struct.stopFreq_MHz  = stopFreq;
    metadata_struct.measType      = measType;
    metadata_struct.timestamp     = datetime('now');
    metadata_struct.instrumentID  = strtrim(query(ENA,'*IDN?'));

    % %% Data container passed to saveData (column vectors)
    % sweepData.f         = fdata(:);   % same unit as plotted axis (GHz)
    % sweepData.mag_dB    = mag(:);
    % sweepData.phase_deg = phase(:);
    % sweepData.meta      = meta;

    %% Plotting (default behaviour)
    if ~exist('opt','var')
        subPlotFigure = figure(getNextMATLABFigNum());

        subplot(1,2,1);
        plotData(fdata,mag,'xLabel',"Frequency (GHz)", ...
            'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1);

        subplot(1,2,2);
        [~,myFig] = plotData(fdata,phase,'xLabel',"Frequency (GHz)", ...
            'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1);

        % subPlotFigure.UserData = meta;   % metadata travels with the .fig
    end

    myFig.UserData = metadata_struct;
    disp(metadata_struct);

    %% Save figure (if any) + raw data, then increment file counter
    saveData(subPlotFigure,tag);
end