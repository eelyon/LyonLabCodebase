% Script used to initialize an experiment.

port = 1234;

% QDAC-II
qDACPort = 'COM8';
qDACIPAddress = '172.29.117.61';

% SR830s
VmeasTop_Address    = '172.29.117.106';    

% Keysight AWG (1)
AWG_1_Address = '172.29.117.60';
AWG_2_Address = '172.29.117.57';
% AgTwd_Address = '172.29.29.6';
% AgComp_Address = '172.29.117.17';

% ENA 
ENA_Address = '172.29.117.72';

%% Connect

qDAC = QDAC(qDACIPAddress, 24, 'qDAC');
baselDAC = baselDAC('172.29.117.62',24,'baselDAC');

%SR830Twiddle  = SR830(port,VmeasBottom_Address);
SR830Top = SR830(port,VmeasTop_Address);

Awg_1 = Agilent33622A(port,AWG_1_Address,1); % two-channel AWG
Awg_2 = Agilent33622A(port,AWG_2_Address,1); % two-channel AWG
% AwgTwd     = Agilent33220A(port,AgTwd_Address,1); % AWG
% AwgComp    = Agilent33220A(port,AgComp_Address,1); % AWG

controlDACGUI = QDACGUI_controlTL;

DCMap_BFC;

% Initialize Misc
% ENA = KeysightE5071(ENA_Address);
% setKeysightE5071PresetConfig(ENA,'HeLevelRes')

%% Old
% VmeasBottom_Address = '172.29.117.102';
%hDACPort = 'COM5';
% hDAC = HarvardDAC(hDACPort,'hDAC',8);
% qDAC = QDACCOM(qDACPort,24,'qDAC'); 
%supplyDACGUI = HarvardDACGUI;

