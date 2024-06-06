%% Script used to initialize an experiment. Comment/uncomment what is needed.
port = 1234; % for the big glass dewar

%% Thermometer
% DMM_Address = '172.29.117.107';
% Thermometer = TCPIP_Connect(DMM_Address,port);

%% Keysight VNA E5071
% initializeENA;

%% AJS's 24 channel DACs
sigDACPortControl = 'COM6'; % 20-bit DAC
sigDACPortSupply  = 'COM8'; % 18-bit DAC
controlDAC = sigDAC(sigDACPortControl,24,'controlDAC');
supplyDAC = sigDAC(sigDACPortSupply,24,'supplyDAC');

%% SR830 Lock-ins
st_Address = '172.29.117.103'; % bottom SR830
twiddle_Address = '172.29.117.106'; % top SR830
SR830ST = SR830(port,st_Address); % for Sommer-Tanner
SR830Twiddle = SR830(port,twiddle_Address); % for twiddle

%% Filament
% DMM_Address = '172.29.117.107'; % Keysight DMM
% Fil_Address = '172.29.117.127'; % Agilent for Filament

%% Agilents for pulsed door experiment (copied from Tiffany)
% Ag2Channel = Agilent33622A(1234,'172.29.117.133',1); % two-channel AWG
% Vpuls1_Address = '172.29.117.125';
% Vpuls2_Address = '172.29.117.126';
% VpulsTrig_Address = '172.29.117.123';

% VtwiddleE = Agilent33220A(port,VtwiddleE_Address,1);
% VdoorModE = Agilent33220A(port,VdoorModE_Address,1);

% VtwiddleC = Agilent33220A(port,VtwiddleC_Address,1);
% VdoorModC = Agilent33220A(port,VdoorModC_Address,1); 

% Vpuls1 = Agilent33220A(port,Vpuls1_Address,1);
% Vpuls2 = Agilent33220A(port,Vpuls2_Address,1);
% VpulsTrig = Agilent33220A(port,VpulsTrig_Address,1);

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