%% Set single frequency sweep
close all;

power     = -10;      % in dBm - be careful!! Do not set too high!!
startFreq = 2110;    % in MHz 2130
stopFreq  = 2123;    % in MHz 2148

% decide whether to include metadata (1=include,0=don't)
saveFig   = 1;       % for saving the figure
tag = 'HeLevelMeter';

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
% loc = findpeaks(fdata,'MinPeakProminence',1); % finds approx resonance frequency
% fres = fdata(loc);

%% Plot data
measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
subPlotFigure = figure(getNextMATLABFigNum());

subplot(1,2,1);
freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1,'type',"linear");
subplot(1,2,2);
[freqvsphase,myFig] = plotData(fdata,phase,'xLabel',"Frequency (GHz)",'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1,'type',"linear");


% sgtitle(['f_{res}=', num2str(fres*1e3),'MHz']);

% metadata_struct.power = [num2str(power)];
% metadata_struct.fres  = [num2str(fres)];

% myFig.UserData = metadata_struct;
% disp(metadata_struct);

if saveFig == 1
    plotHandles = {freqvsmag,freqvsphase};
    saveData(subPlotFigure,tag); % Save mag and phase data
end