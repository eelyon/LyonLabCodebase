%% Initialise ENA
ENA.InputBufferSize = 32000;
port = 5025;
ipAddress = '172.29.117.72';
ENA = TCPIP_Connect(ipAddress,port);

%% Set up the ENA
E5071SetAvg(ENA,'Off');
E5071SetIFBand(ENA,5); % in kHz
E5071SetSweepTime(ENA,4); % in secs
E5071SetNumPoints(ENA,3000);
E5071SetMeas(ENA,1,'S21');
E5071SetPower(ENA,-30); % in dBm

E5071SetStartFreq(ENA,2000); % in MHz
E5071SetStopFreq(ENA,2200); % in MHz

%% Get mag (log) and phase (deg) data
[xdata,ydata] = E5071GetData(ENA,'test');
plotData(xdata,ydata,'xLabel','Frequency (GHz)','yLabel','Power (dBm)','color','r.','Title',[tag '']);
% saveData(freqSweepHandle,tag);