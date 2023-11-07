% fopen(ENA) % open client connection
% fclose(ENA) % close client connection, or: clear ENA
% query(ENA,'*IDN?') % check connection to ENA

%% Set up ENA
% fprintf(ENA,':SYST:KLOC:KBD OFF'); % Lock front panel and keyboard
% fprintf(ENA,':SYST:KLOC:MOUS OFF'); % Lock mouse and touch screen

E5071SetAvg(ENA,'Off'); % Turn off averaging
E5071SetMeas(ENA,1,'S21'); % S11, S12, S21, S22
%E5071SetPower(ENA,-20); % in dBm
E5071SetNumPoints(ENA,4000); % set no. of points
E5071SetDataFormat(ENA,'PLOG'); % SLIN, SLOG, SCOM, SMIT, SADM, PLIN, PLOG, or POL
%E5071SetDelay(ENA,500,2200); % correct for electrical delay
E5071SetIFBand(ENA,1); % in kHz
E5071SetSweepTime(ENA,4); % in secs