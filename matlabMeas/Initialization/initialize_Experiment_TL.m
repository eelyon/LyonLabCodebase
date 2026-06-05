% Script used to initialize an experiment.

port = 1234;
    
% Anthony's 24 channel DACs
sigDACPortControl = 'COM8';
sigDACPortSupply  = 'COM4';

% SR830s
VmeasTop_Address    = '172.29.117.106';    
VmeasBottom_Address = '172.29.117.103';

% Agilent DMM
DMM_Address = '172.29.117.107';

% Keysight AWG (Houck)
houckAWG_Address = '172.29.117.137';

% Black Keysight AWG (Natalie)
deLeonAWG_Address = '172.29.117.24';
% AWGTwiddle_Address = '172.29.117.16';
% AWGComp_Address = '172.29.117.17';

% Black Keysight Door AWG
door_Address = '172.29.117.57';

% Oscilloscope
oscope_Address = 'USB0::0x0699::0x03A5::C011465::0';

%% Connect
controlDAC = sigDAC(sigDACPortControl,24,'controlDAC');
supplyDAC  = sigDAC(sigDACPortSupply,24,'supplyDAC');
controlDACGUI = sigDACGUI_controlTL;
supplyDACGUI  = sigDACGUI_supplyTL;
% SR830Gui = SR830_GUI;

SR830Twiddle  = SR830(port,VmeasBottom_Address);
SR830TwiddleC = SR830(1234,VmeasTop_Address);

Awg2Ch = Agilent33622A(1234,houckAWG_Address,1); % two-channel AWG
Awg2Nat = Agilent33622A(1234,deLeonAWG_Address,1); % two-channel AWG
AwgDoor = Agilent33622A(1234,door_Address,1); % two-channel AWG
% AwgTwiddle = Agilent33220A(1234,AWGTwiddle_Address,1); % AWG
% AwgComp    = Agilent33220A(1234,AWGComp_Address,1); % AWG

Thermometer = TCPIP_Connect(DMM_Address,port);


% Oscope = TDS2022C(oscope_Address);
% % IDC = SIM900(IDCPort);
% VpulsSig = SDG5122(Sig_Address);
% % Filament = Agilent33220A(port,'172.29.117.127',1);

% GUI = Tiffany_GUI;
DCMap;