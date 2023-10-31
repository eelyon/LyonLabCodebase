%% Initialise ENA
%port = 5025;
%ipAddress = '172.29.117.72';
%ENA = TCPIP_Connect(ipAddress,port);
%ENA.InputBufferSize = 32000;

%% Set up ENA
E5071SetAvg(ENA,'Off');
E5071SetIFBand(ENA,1); % in kHz
E5071SetSweepTime(ENA,4); % in secs
E5071SetNumPoints(ENA,4000);
E5071SetMeas(ENA,1,'S21'); % S11, S12, S21, S22
E5071SetPower(ENA,-30); % in dBm

E5071SetStartFreq(ENA,2000); % in MHz
E5071SetStopFreq(ENA,3000); % in MHz

E5071SetDataFormat(ENA,'PLOG'); % SLIN, SLOG, SCOM, SMIT, SADM, PLIN, PLOG, or POL

%fprintf(ENA,':INIT1:CONT '); % Turn on continuous initiation mode
%fprintf(ENA,':TRIG:SING '); % Set trigger source to "Bus Trigger"

%fprintf(ENA,':SYST:KLOC:KBD OFF') % Lock front panel and keyboard
%fprintf(ENA,':SYST:KLOC:MOUS OFF') % Lock mouse and touch screen