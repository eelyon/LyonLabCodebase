%% Script used to initialize an experiment. Comment/uncomment what is needed.
% port = 1234; % for the big glass dewar

%% Thermometer
% DMM_Address = '172.29.117.107';
% Thermometer = TCPIP_Connect(DMM_Address,port);

%% Keysight VNA E5071
% initializeENA;

%% AJS's 24 channel DACs
controlDAC = sigDAC('COM8',24,'controlDAC')
supplyDAC = sigDAC('COM4',24,'supplyDAC')

%% SIM900 for biasing HEMTs
sim900 = SIM900('COM5')

%% DC pinout script
% DCPinout;

%% SR830 Lock-ins
% top_Address = '172.29.117.106'; % top SR830
% bottom_Address = '172.29.117.103'; % bottom SR830
SR830ST = SR830(1234,"172.29.117.103") % for Sommer-Tanner
% SR830Twiddle = SR830(port,bottom_Address); % for twiddle

%% Filament
% DMM_Address = '172.29.117.107'; % Keysight DMM
% Fil_Address = '172.29.117.127'; % Agilent for Filament

%% Agilent AWGs
awg2ch_1 = Agilent33622A(1234,'172.29.117.24')
awg2ch_2 = Agilent33622A(1234,'172.29.117.62')
awg2ch_3 = Agilent33622A(1234,'172.29.117.57')
awg2ch_houck = Agilent33622A(1234,'172.29.117.137') % Borrowed from Houck lab (lowest noise)

% AwgTwiddle_Address = '172.29.117.16';
% AwgTwiddle = Agilent33220A(1234,AwgTwiddle_Address,1); % 1-channel AWG
% AwgComp_Address = '172.29.117.17';
% AwgComp = Agilent33220A(1234,AwgComp_Address,1); % 1-channel AWG

awgFilament = Agilent33220A(port,'172.29.117.127',1)
% Siglent power supply address
siglentFilament = SPD330('172.29.117.8',1)

%% GUIs
controlDACGUI = sigDACGUI;
% % controlDACGUI.Inst_NameEditField.Value = 'controlDAC';
% % controlDACGUI.numChanEditField.Value = 24;
% 
supplyDACGUI = sigDACGUI;
% % supplyDACGUI.Inst_NameEditField.Value = 'supplyDAC';
% % supplyDACGUI.numChanEditField.Value = 24;

% SR830GUI = SR830_GUI;

% % SR830SWEEPGUI = sweepSR830GUI;
% % SR830SWEEPGUI.SR830ReadEditField.Value = 'SR830';
% % SR830SWEEPGUI.SweepDeviceEditField.Value = 'DAC';
% % SR830SWEEPGUI.numRepeatsEditField.Value = 9;