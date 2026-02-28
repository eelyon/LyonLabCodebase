% Script used to initialize an experiment.

port = 1234;

% Anthony's 24 channel DACs
% sigDACPortControl = 'COM8';

% QDAC-II
qDACPort = 'COM8';
qDACIPAddress = '172.29.117.61';

% Harvard DAC
hDACPort = 'COM5';

% SR830s
VmeasTop_Address    = '172.29.117.106';    
VmeasBottom_Address = '172.29.117.102';

% Keysight AWG (1)
AWG_1_Address = '172.29.117.60';
% Agilent AWG (2)
% AWG_2_Address = '172.29.117.57';
AgTwd_Address = '172.29.29.6';
AgComp_Address = '172.29.117.17';

%% Connect

% qDAC = QDACCOM(qDACPort,24,'qDAC'); 
qDAC = QDAC(qDACIPAddress, 24, 'qDAC');
hDAC = HarvardDAC(hDACPort,'hDAC',8);
SR830Twiddle  = SR830(port,VmeasBottom_Address);
SR830TwiddleC = SR830(port,VmeasTop_Address);

Awg_1 = Agilent33622A(port,AWG_1_Address,1); % two-channel AWG
%Awg_2 = Agilent33622A(port,AWG_2_Address,1); % two-channel AWG
AwgTwd     = Agilent33220A(port,AgTwd_Address,1); % AWG
AwgComp    = Agilent33220A(port,AgComp_Address,1); % AWG

controlDACGUI = QDACGUI_controlTL;
supplyDACGUI = HarvardDACGUI;

DCMap_BFC;

% Initialize Misc
initializeENA
setupENA_GF