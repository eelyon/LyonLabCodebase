%% Script used to initialize an experiment. Comment/uncomment what is needed.
% port = 1234; % for the big glass dewar

%% Keysight VNA E5071
% ENA = KeysightE5071(ENA_Address);
% setKeysightE5071PresetConfig(ENA,'HeLevelRes')

%% DACs
% qDACPort = 'COM8';
qDAC = QDAC('172.29.117.61', 24, 'qDAC')
baselDAC = baselDAC('172.29.117.62',24,'baselDAC')
% hDAC = HarvardDAC('COM5','hDAC',8);

%% SIM900 for biasing HEMTs
% sim900 = SIM900('COM5')

%% DC pinout script
pinout_sandia_roic;

%% SR830 Lock-ins
SR830 = SR830(1234,"172.29.117.106") % for Sommer-Tanner

%% Filament
% DMM_Address = '172.29.117.107'; % Keysight DMM
% Fil_Address = '172.29.117.127'; % Agilent for Filament

%% Agilent AWGs
awg2ch_1 = Agilent33622A(1234,'172.29.117.57')
awg2ch_2 = Agilent33622A(1234,'172.29.117.60')
awgFilament = Agilent33220A(1234,'172.29.117.16',1)

% Siglent power supply address
siglentFilament = SPD330('172.29.117.67',1)

%% GUIs
controlDACGUI = QDACGUI_controlTL;