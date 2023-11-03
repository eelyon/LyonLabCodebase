%% Initialise ENA
port = 5025;
ipAddress = '172.29.117.72';
ENA = TCPIP_Connect(ipAddress,port); % tcpclient is new version
ENA.InputBufferSize = 32000;

%% Set up ENA
% fprintf(ENA,':SYST:KLOC:KBD OFF'); % Lock front panel and keyboard
% fprintf(ENA,':SYST:KLOC:MOUS OFF'); % Lock mouse and touch screen
E5071SetAvg(ENA,'Off'); % Turn off averaging
E5071SetMeas(ENA,1,'S21'); % S11, S12, S21, S22
E5071SetPower(ENA,-30); % in dBm
E5071SetNumPoints(ENA,4000); % set no. of points
E5071SetDataFormat(ENA,'PLOG'); % SLIN, SLOG, SCOM, SMIT, SADM, PLIN, PLOG, or POL
E5071SetDelay(ENA,500,4000); % correct for electrical delay
E5071SetIFBand(ENA,1); % in kHz
E5071SetSweepTime(ENA,4); % in secs

% fopen(ENA) % open client connection
% fclose(ENA) % close client connection, or: clear ENA
% query(ENA,'*IDN?') % check connection to ENA