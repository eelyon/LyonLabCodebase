% for plotting S21, S11 of BFC Coax

% Set up
%initializeENA
% E5071SetAvg(ENA,'Off'); % Turn off averaging
E5071SetMeas(ENA,1,'S21'); % S11, S12, S21, S22
E5071SetNumPoints(ENA,5000); % set no. of points
% E5071SetDataFormat(ENA,'PLOG'); % SLIN, SLOG, SCOM, SMIT, SADM, PLIN, PLOG, or POL
E5071SetIFBand(ENA,50); % in kHz
% E5071SetSweepTime(ENA,4); % in secs

%% Set single frequency sweep
close all;

power     = -5;      % in dBm - be careful!! Do not set too high!!
startFreq = 0.3;    % in MHz
stopFreq  = 14000;    % in MHz 

% decide whether to include metadata (1=include,0=don't)
saveFig   = 1;       % for saving the figure
tag ='PORT-15 S21';

E5071SetPower(ENA,power);           % in dBm
E5071SetStartFreq(ENA,startFreq);   % in MHz
E5071SetStopFreq(ENA,stopFreq);     % in MHz

flush(ENA);
pause(0.1)
fprintf(ENA,':INIT1');         % Set trigger value - for continuous set: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING');     % Trigger ENA to start sweep cycle
query(ENA,'*OPC?');            % Execute *OPC? command and wait until command return 1

% Get mag (log) and phase (deg) data
[fdata,mag,phase] = E5071GetData(ENA,tag);

%% Plot data
measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
subPlotFigure = figure(getNextMATLABFigNum());

freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b",'subPlot',1,'type',"linear",'legend',tag);
sgtitle('S21 Measurement BFC Coax');


if saveFig == 1
    plotHandles = {freqvsmag,freqvsphase};
    saveData(subPlotFigure,tag); % Save mag and phase data
end


E5071SetMeas(ENA,1,'S11'); % S11, S12, S21, S22

%% Set single frequency sweep
power     = -5;      % in dBm - be careful!! Do not set too high!!
startFreq = 0.3;    % in MHz
stopFreq  = 14000;    % in MHz 

% decide whether to include metadata (1=include,0=don't)
saveFig   = 1;       % for saving the figure
tag ='PORT-15 S11';

E5071SetPower(ENA,power);           % in dBm
E5071SetStartFreq(ENA,startFreq);   % in MHz
E5071SetStopFreq(ENA,stopFreq);     % in MHz

flush(ENA);
pause(0.1)
fprintf(ENA,':INIT1');         % Set trigger value - for continuous set: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING');     % Trigger ENA to start sweep cycle
query(ENA,'*OPC?');            % Execute *OPC? command and wait until command return 1

% Get mag (log) and phase (deg) data
[fdata,mag,phase] = E5071GetData(ENA,tag);

%% Plot data
measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
subPlotFigure = figure(getNextMATLABFigNum());

freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b",'subPlot',1,'type',"linear",'legend',tag);
sgtitle('S11 Measurement BFC Coax');


if saveFig == 1
    plotHandles = {freqvsmag,freqvsphase};
    saveData(subPlotFigure,tag); % Save mag and phase data
end