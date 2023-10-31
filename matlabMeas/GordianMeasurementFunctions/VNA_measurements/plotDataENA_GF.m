% Set trigger value
%E5071SetTrig(ENA,'SINGLE');
%pause(str2num(query(ENA,'SENS1:SWE:TIME?')))

fprintf(ENA,':INIT1:IMM'); % Set trigger value - continuous: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING');
query(ENA,'*OPC?')

% Get mag (log) and phase (deg) data
[fdata,mag,phase] = E5071GetData(ENA,'test');

% Plot mag and phase data
closeAllFigures;
plotData(fdata,mag);
plotData(fdata,phase);

% Save mag and phase data
% saveData(freqSweepHandle,tag);