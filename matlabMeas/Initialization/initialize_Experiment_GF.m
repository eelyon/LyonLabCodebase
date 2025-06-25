%% Script used to initialize an experiment. Comment/uncomment what is needed.
port = 1234; % for the big glass dewar

%% Thermometer
% DMM_Address = '172.29.117.107';
% Thermometer = TCPIP_Connect(DMM_Address,port);

%% Keysight VNA E5071
% initializeENA;

%% AJS's 24 channel DACs
sigDACPortControl = 'COM4'; % 20-bit DAC
sigDACPortSupply  = 'COM8'; % 18-bit DAC
controlDAC = sigDAC(sigDACPortControl,24,'controlDAC');
supplyDAC = sigDAC(sigDACPortSupply,24,'supplyDAC');

%% SIM900 for biasing HEMTs
% sim900Port = 'COM5';
% sim900 = SIM900(sim900Port);

%% DC pinout script
% DCPinout;

%% SR830 Lock-ins
st_Address = '172.29.117.106'; % top SR830
twiddle_Address = '172.29.117.103'; % bottom SR830
SR830ST = SR830(port,st_Address); % for Sommer-Tanner
SR830Twiddle = SR830(port,twiddle_Address); % for twiddle

%% Filament
% DMM_Address = '172.29.117.107'; % Keysight DMM
% Fil_Address = '172.29.117.127'; % Agilent for Filament

%% Agilent AWGs
% deLeonAWG_Address = '172.29.117.133';
% Awg2ch_deLeon = Agilent33622A(1234,deLeonAWG_Address,1); % two-channel AWG
Awg2chHouck_Address = '172.29.117.137';
Awg2ch = Agilent33622A(1234,Awg2chHouck_Address,1); % two-channel AWG

AwgTwiddle_Address = '172.29.117.16';
AwgTwiddle = Agilent33220A(1234,AwgTwiddle_Address,1); % 1-channel AWG
AwgComp_Address = '172.29.117.17';
AwgComp = Agilent33220A(1234,AwgComp_Address,1); % 1-channel AWG

% AwgFilament = Agilent33220A(port,'172.29.117.127',1);

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